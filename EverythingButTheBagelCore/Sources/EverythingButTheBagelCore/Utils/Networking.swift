import Dependencies
import Foundation

struct Repository<ResponseType: Decodable>: DependencyKey, StaticLoggingContext {
  static var loggingCategory: String {
    "Networking"
  }
  static var networkRequest: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
    Dependency(\.networkRequest).wrappedValue
  }

  /// Send a request, attempt to parse respose to `ResponseType` and do some processing on errors.
  ///
  /// Makes use of the built in cache. Cache policy can be set as a part of the the `request` parameter.
  /// Any responses with a status code outside of the 200 range are treated as errors.
  static var liveValue: @Sendable (
    _ request: URLRequest
  ) async throws -> ResponseType {
    { request in
      let data = try await self.makeRequest(request)

      // Sometimes we just want the data back, for example when downloading an image
      // JSONDecoder can't parse raw data as JSON, so it falls over
      if ResponseType.self == Data.self, let data = data as? ResponseType {
        return data
      }

      let decoder = JSONDecoder()
      return try logErrors {
        try decoder.decode(ResponseType.self, from: data)
      }
    }
  }

  static var testValue: @Sendable (URLRequest) async throws -> ResponseType {
    unimplemented("repository")
  }

  /// Send a request and do some processing on errors.
  ///
  /// Makes use of the built in cache. Cache policy can be set as a part of the the `request` parameter.
  /// Any responses with a status code outside of the 200 range are treated as errors.
  static func makeRequest(_ request: URLRequest) async throws -> Data {
    // This function just wraps `makeRequestInternal` and provides logging of errors
    try await logErrors {
      guard let url = request.url else {
        // The docs don't say under what circumstances this is possible
        throw NetworkRequestError.malformedRequest(message: "URLRequest was missing a url")
      }
      log(.info(message: "Making a request to \(url), with policy \(request.cachePolicy)"))
      return try await makeRequestInternal(request)
    }
  }

  private static func makeRequestInternal(_ request: URLRequest) async throws -> Data {
    // Map response to a HTTPURLResponse, or throw an error if that's not possible
    let result = await Result { try await networkRequest(request) }.flatMap { (data, response) in
      if let response = response as? HTTPURLResponse {
        return .success((data, response))
      } else {
        return .failure(NetworkRequestError.malformedResponse(
          message: "Response was not an HTTPURLResponse"
        ))
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

public enum NetworkRequestError: Error {
  case transportError(EquatableError)
  case serverError(statusCode: Int)
  case malformedRequest(message: String)
  case malformedResponse(message: String)
}

extension NetworkRequestError {
  public static func malformedURLError(urlString: String) -> NetworkRequestError {
    NetworkRequestError.malformedRequest(
      message: "Attempted to connect to a malformed URL: \(urlString)"
    )
  }
}

private let ephemeralConfig = {
  var config = URLSessionConfiguration.ephemeral
  config.httpShouldSetCookies = false
  config.urlCache = nil
  config.requestCachePolicy = .reloadIgnoringLocalCacheData
  return config
}()

private let ephemeralSession = URLSession(configuration: ephemeralConfig)

struct EphemeralNetworkRequestKey: DependencyKey {
  static let liveValue: @Sendable (URLRequest) async throws -> (Data, URLResponse) = ephemeralSession.data
  static let testValue: @Sendable (URLRequest) async throws -> (Data, URLResponse) = unimplemented("network request")
}

extension DependencyValues {
  /// Wrapper around `URLSession.data(for:)` that doesn't cache
  var ephemeralNetworkRequest: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
    get { self[EphemeralNetworkRequestKey.self] }
    set { self[EphemeralNetworkRequestKey.self] = newValue }
  }
}

struct NetworkRequestKey: DependencyKey {
  static let liveValue: @Sendable (URLRequest) async throws -> (Data, URLResponse) = URLSession.shared.data
  static let testValue: @Sendable (URLRequest) async throws -> (Data, URLResponse) = unimplemented("network request")
}

extension DependencyValues {
  /// Wrapper around `URLSession.data(for:)`
  var networkRequest: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
    get { self[NetworkRequestKey.self] }
    set { self[NetworkRequestKey.self] = newValue }
  }
}

struct CacheConfigurationKey: DependencyKey {
  static let liveValue: @Sendable (
    _ memoryCapacity: Int?,
    _ diskCapacity: Int?
  ) -> Void = { memoryCapacity, diskCapacity in
    // TODO: Replace `URLCache`
    // According to docs, will evict contents from the cache if the capacity is set lower than the
    // size of the current contents
    if let memoryCapacity {
      URLSession.shared.configuration.urlCache?.memoryCapacity = memoryCapacity
    }

    if let diskCapacity {
      URLSession.shared.configuration.urlCache?.diskCapacity = diskCapacity
    }
  }
  static let testValue: @Sendable (_ memoryCapacity: Int?, _ diskCapacity: Int?) -> Void
    = unimplemented("cache configuration")
}

extension DependencyValues {
  /// Configures the capacity of memory and disk caches for `URLSession`.
  ///
  /// According to
  /// [a blog post](https://web.archive.org/web/20230608175638/https://zhuk.fi/subclassing-urlcache/)
  /// the default eviction policy for `URLCache` is to delete *the entire cache* when the capacity limit is
  /// reached. For the time being this is acceptable, but we may have to replace `URLCache` in the future
  /// with one with a more reasonable eviction policy ie LRU, LRU2, LFU
  var cacheConfiguration: @Sendable (_ memoryCapacity: Int?, _ diskCapacity: Int?) -> Void {
    get { self[CacheConfigurationKey.self] }
    set { self[CacheConfigurationKey.self] = newValue }
  }
}

public enum SessionConfig: Sendable {
  case ephemeral
  case cached
}
