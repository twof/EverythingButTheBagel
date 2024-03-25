import Dependencies
import Foundation

struct Repository: LoggingContext {
  static let loggingCategory = "Networking"
  @Dependency(\.networkRequest) var networkRequest
  @Dependency(\.cacheConfiguration) var cacheConfiguration
  
  /// Memory and disk capacity of the builtin URL cache. nil values will keep the defaults.
  init(memoryCapacity: Int? = nil, diskCapacity: Int? = nil) {
    cacheConfiguration(memoryCapacity, diskCapacity)
  }
  
  /// Send a request and do some processing on errors.
  ///
  /// Makes use of the built in cache. Cache policy can be set as a part of the the `request` parameter.
  /// Any responses with a status code outside of the 200 range are treated as errors.
  func makeRequest(_ request: URLRequest) async throws -> Data {
    // This function just wraps `makeRequestInternal` and provides logging of errors
    try await logErrors {
      guard let url = request.url else {
        // The docs don't say under what circumstances this is possible
        throw NetworkRequestError.malformedRequest(message: "URLRequest was missing a url")
      }
      log(.info(message: "Making a request to \(url), with policy \(request.cachePolicy)"))
      return try await self.makeRequestInternal(request)
    }
  }
  
  private func makeRequestInternal(_ request: URLRequest) async throws -> Data {
    // Map response to a HTTPURLResponse, or throw an error if that's not possible
    let result = await Result { try await networkRequest(request) }.flatMap { (data, response) in
      if let response = response as? HTTPURLResponse {
        return .success((data, response))
      } else {
        return .failure(NetworkRequestError.malformedResponse(message: "Response was not an HTTPURLResponse"))
      }
    }
    
    // Throw error if response code is outside of the 200 range or if URLSession throws an error
    return switch result {
    case let .success((data, response)) where (200...299).contains(response.statusCode): data
    case let .success((_, response)):
      throw NetworkRequestError.serverError(statusCode: response.statusCode)
    case let .failure(error):
      throw NetworkRequestError.transportError(error.toEquatableError())
    }
  }
}

enum NetworkRequestError: Error {
  case transportError(EquatableError)
  case serverError(statusCode: Int)
  case malformedRequest(message: String)
  case malformedResponse(message: String)
}

struct NetworkRequestKey: DependencyKey {
  static var liveValue: (URLRequest) async throws -> (Data, URLResponse) = URLSession.shared.data
  static var testValue: (URLRequest) async throws -> (Data, URLResponse) = unimplemented("network request")
}

extension DependencyValues {
  var networkRequest: (URLRequest) async throws -> (Data, URLResponse) {
    get { self[NetworkRequestKey.self] }
    set { self[NetworkRequestKey.self] = newValue }
  }
}

struct CacheConfigurationKey: DependencyKey {
  static var liveValue: (_ memoryCapacity: Int?, _ diskCapacity: Int?) -> Void = { memoryCapacity, diskCapacity in
    // According to docs, will evict contents from the cache if the capacity is set lower than the
    // current contents
    if let memoryCapacity {
      URLSession.shared.configuration.urlCache?.memoryCapacity = memoryCapacity
    }
    
    if let diskCapacity {
      URLSession.shared.configuration.urlCache?.diskCapacity = diskCapacity
    }
  }
  static var testValue: (_ memoryCapacity: Int?, _ diskCapacity: Int?) -> Void = unimplemented("cache configuration")
}

extension DependencyValues {
  var cacheConfiguration: (_ memoryCapacity: Int?, _ diskCapacity: Int?) -> Void {
    get { self[CacheConfigurationKey.self] }
    set { self[CacheConfigurationKey.self] = newValue }
  }
}
