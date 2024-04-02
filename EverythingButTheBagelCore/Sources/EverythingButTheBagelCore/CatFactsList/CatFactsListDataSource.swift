import ComposableArchitecture
import Foundation

@Reducer
public struct CatFactsListDataSource: ErrorProducer {
  static let errorId = String(describing: Self.self)
  public struct State: Codable, Equatable { public init() { } }

  public enum Action: Equatable {
    public enum Delegate: Equatable {
      case factsResponse(CatFactsResponseModel)
      case error(EquatableError)
    }

    case fetchFacts(count: Int)
    case delegate(Delegate)
  }

  @Dependency(\.fetchCatFacts) var fetchCatFacts

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case let .fetchFacts(count):
        return .run { send in
          let factsResponse = try await fetchCatFacts(count)
          await send(.delegate(.factsResponse(factsResponse)))
        } catch: { error, send in
          await send(.delegate(.error(error.toEquatableError())))
        }
      case .delegate:
        // This action acts as a delegate. The data source doesn't do anything with the data itself
        return .none
      }
    }
  }
}

public struct CatFactsResponseModel: Codable, Equatable {
  let currentPage: Int
  let data: [CatFactModel]
  let nextPageUrl: URL?

  // API uses snake case keys
  enum CodingKeys: String, CodingKey {
    case currentPage = "current_page"
    case data
    case nextPageUrl = "next_page_url"
  }
}

public struct CatFactModel: Codable, Equatable {
  let fact: String
}

// Networking client for the
struct FetchCatFactsKey: DependencyKey {
  static let liveValue: (_ count: Int) async throws -> CatFactsResponseModel = { count in
    let urlString = "https://catfact.ninja/facts?limit=\(count)"
    guard let url = URL(string: urlString) else {
      throw NetworkRequestError.malformedRequest(message: "Attempted to connect to a malformed URL: \(urlString)")
    }

    @Dependency(\.repositoryGenerator) var repositoryGenerator
    let repository = repositoryGenerator()
    var urlRequest = URLRequest(url: url)
    urlRequest.cachePolicy = .reloadIgnoringLocalCacheData

    return try await repository.makeRequest(urlRequest, modelType: CatFactsResponseModel.self)
  }
}

extension DependencyValues {
  var fetchCatFacts: (_ count: Int) async throws -> CatFactsResponseModel {
    get { self[FetchCatFactsKey.self] }
    set { self[FetchCatFactsKey.self] = newValue }
  }
}
