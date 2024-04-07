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

    case fetch(url: String, cachePolicy: NSURLRequest.CachePolicy, retry: Int = 0)
    case delegate(Delegate)
  }

  var errorId: String
  let maxRetries: Int

  init(errorId: String, maxRetries: Int = 5) {
    self.errorId = errorId
    self.maxRetries = maxRetries
  }

  @Dependency(DataRequestClient<ResponseType>.self) var fetchDataClient
  @Dependency(\.continuousClock) var clock

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case let .fetch(urlString, cachePolicy, retry):
        return .run { send in
          let response = try await fetchDataClient.request(
            urlString: urlString,
            cachePolicy: cachePolicy
          )
          await send(.delegate(.response(response)))
        } catch: { error, send in
          await send(.delegate(.error(error.toEquatableError())))

          // Begin doing exponential backoff
          if retry < maxRetries {
            do {
              try await clock.sleep(for: .milliseconds(Self.backoffDuration(retry: retry)))
              await send(.fetch(url: urlString, cachePolicy: cachePolicy, retry: retry + 1))
            } catch {
              // This is expected to throw on cancelation which is an error we don't have to deal with
              return
            }
          }
        }
      case .delegate:
        // This action acts as a delegate. The data source doesn't do anything with the data itself.
        return .none
      }
    }
  }

  static func backoffDuration(retry: Int) -> Int {
    let exponent = NSDecimalNumber(value: pow(2, Double(retry))).intValue
    let waitMilliseconds: Int = 100 + exponent
    return waitMilliseconds
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
        let error = NetworkRequestError.malformedURLError(urlString: urlString)
        loggingClient.log(level: .error(error: error.toEquatableError()), category: "Networking")
        throw error
      }

      @Dependency(Repository<ResponseType>.self) var repository
      var urlRequest = URLRequest(url: url)
      urlRequest.cachePolicy = cachePolicy

      return try await repository(urlRequest)
    }
  }

  static var testValue: DataRequestClient<ResponseType> {
    // All properties unimplemented. Will autofail if used in tests.
    DataRequestClient()
  }
}
