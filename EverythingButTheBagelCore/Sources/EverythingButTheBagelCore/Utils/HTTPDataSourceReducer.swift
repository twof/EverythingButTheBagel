import ComposableArchitecture
import Foundation

/// Abstract data source which fetches data from a URL.
/// Handles logging and error handling under the hood.
@Reducer
public struct HTTPDataSourceReducer<ResponseType: Codable & Equatable>: ErrorProducer {
  public struct State: Codable, Equatable { public init() { } }

  public enum Action: Equatable {
    public enum Delegate: Equatable {
      case response(ResponseType)
      case error(EquatableError)
    }

    case fetch(url: String, cachePolicy: NSURLRequest.CachePolicy)
    case delegate(Delegate)
  }

  var errorId: String

  init(errorId: String) {
    self.errorId = errorId
  }

  @Dependency(DataRequestClient<ResponseType>.self) var fetchDataClient

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case let .fetch(urlString, cachePolicy):
        return .run { send in
          let response = try await fetchDataClient.request(
            urlString: urlString,
            cachePolicy: cachePolicy
          )
          await send(.delegate(.response(response)))
        } catch: { error, send in
          await send(.delegate(.error(error.toEquatableError())))
        }
      case .delegate:
        // This action acts as a delegate. The data source doesn't do anything with the data itself.
        return .none
      }
    }
  }
}

@DependencyClient
struct DataRequestClient<ResponseType: Codable & Equatable> {
  var request: (
    _ urlString: String,
    _ cachePolicy: NSURLRequest.CachePolicy
  ) async throws -> ResponseType
}

// General networking client
extension DataRequestClient: DependencyKey {
  static var liveValue: DataRequestClient<ResponseType> {
    DataRequestClient { urlString, cachePolicy in
      @Dependency(\.loggingClient) var loggingClient
      guard let url = URL(string: urlString) else {
        let error = NetworkRequestError.malformedRequest(message: "Attempted to connect to a malformed URL: \(urlString)")
        loggingClient.log(level: .error(error: error.toEquatableError()), category: "Networking")
        throw error
      }

      @Dependency(\.repositoryGenerator) var repositoryGenerator
      let repository = repositoryGenerator()
      var urlRequest = URLRequest(url: url)
      urlRequest.cachePolicy = cachePolicy

      return try await repository.makeRequest(urlRequest, modelType: ResponseType.self)
    }
  }

  static var testValue: DataRequestClient<ResponseType> {
    // All properties unimplemented. Will autofail if used in tests.
    DataRequestClient()
  }
}
