import ComposableArchitecture
import Foundation

@Reducer
public struct CatFactsListBase {
  public static let baseURL = "https://catfact.ninja/facts?page=1"

  @ObservableState
  public struct State: Codable, Equatable {
    public var viewModel: CatFactsListViewModelReducer.State
    public var dataSource: HTTPDataSourceReducer<CatFactsResponseModel>.State
    public var refreshDataSource: HTTPDataSourceReducer<CatFactsResponseModel>.State

    var nextPage: URL?

    public init(
      viewModel: CatFactsListViewModelReducer.State = .init(),
      dataSource: HTTPDataSourceReducer<CatFactsResponseModel>.State = .init(),
      refreshDataSource: HTTPDataSourceReducer<CatFactsResponseModel>.State = .init(),
      nextPage: URL? = URL(string: CatFactsListBase.baseURL)
    ) {
      self.viewModel = viewModel
      self.dataSource = dataSource
      self.refreshDataSource = refreshDataSource
      self.nextPage = nextPage
    }
  }

  public enum Action: Equatable {
    case viewModel(CatFactsListViewModelReducer.Action)
    case dataSource(HTTPDataSourceReducer<CatFactsResponseModel>.Action)
    case refreshDataSource(HTTPDataSourceReducer<CatFactsResponseModel>.Action)
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    CombineReducers {
      Scope(state: \.viewModel, action: \.viewModel) {
        CatFactsListViewModelReducer()
      }
      Scope(state: \.dataSource, action: \.dataSource) {
        HTTPDataSourceReducer<CatFactsResponseModel>(errorId: "CatFactsDataSource")
      }
      // TODO: I don't love having two different http data sources here, but there needs to be
      // a way to tell the view model to reset its list of facts on refresh, and I don't want to
      // thread that through the data source type.
      Scope(state: \.refreshDataSource, action: \.refreshDataSource) {
        HTTPDataSourceReducer<CatFactsResponseModel>(errorId: "CatFactsDataSource")
      }
      // The base reducer is primarily responsable for routing data from the data source to
      // the view model, and user interactions from the view model to the data source
      Reduce { state, action in
        switch action {
        case let .dataSource(.delegate(.response(response))):
          state.nextPage = response.nextPageUrl

          return .merge(
            .send(.viewModel(.newFacts(response.data, strategy: .append))),
            .send(.viewModel(.isLoading(false)))
          )

        case let .refreshDataSource(.delegate(.response(response))):
          state.nextPage = response.nextPageUrl

          return .merge(
            .send(.viewModel(.newFacts(response.data, strategy: .reset))),
            .send(.viewModel(.isLoading(false)))
          )

        case .dataSource(.delegate(.error)):
          return .send(.viewModel(.isLoading(false)))

        case .viewModel(.delegate(.task)):
          // Only do the initial fetch if we're not loading from the cache
          if state.viewModel.status.data.isEmpty, let nextPage = state.nextPage?.absoluteString {
            return .send(.dataSource(.fetch(
              url: catFactsURL(baseUrl: nextPage, count: 40),
              cachePolicy: .reloadIgnoringLocalCacheData
            )))
          }

          return .none

        case .viewModel(.delegate(.nextPage)):
          if let nextPage = state.nextPage?.absoluteString {
            return .send(.dataSource(.fetch(
              url: catFactsURL(baseUrl: nextPage, count: 40),
              cachePolicy: .reloadIgnoringLocalCacheData
            )))
          }

          return .none

        case .viewModel(.delegate(.refresh)):
          return .send(.refreshDataSource(.fetch(
            url: catFactsURL(baseUrl: CatFactsListBase.baseURL, count: 40),
            cachePolicy: .reloadIgnoringLocalCacheData
          )))

        case .dataSource(.fetch):
          return .send(.viewModel(.isLoading(true)))

        case .dataSource, .viewModel, .refreshDataSource:
          return .none
        }
      }
    }
  }

  private func catFactsURL(baseUrl: String, count: Int) -> String {
    return "\(baseUrl)&limit=\(count)"
  }
}
