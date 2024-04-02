import ComposableArchitecture

@Reducer
public struct CatFactsListBase {
  @ObservableState
  public struct State: Codable, Equatable {
    public var viewModel: CatFactsListViewModelReducer.State
    public var dataSource: CatFactsListDataSource.State

    public init(
      viewModel: CatFactsListViewModelReducer.State = .init(),
      dataSource: CatFactsListDataSource.State = .init()
    ) {
      self.viewModel = viewModel
      self.dataSource = dataSource
    }
  }

  public enum Action: Equatable {
    case viewModel(CatFactsListViewModelReducer.Action)
    case dataSource(CatFactsListDataSource.Action)
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    CombineReducers {
      Scope(state: \.viewModel, action: \.viewModel) {
        CatFactsListViewModelReducer()
      }
      Scope(state: \.dataSource, action: \.dataSource) {
        CatFactsListDataSource()
      }
      // The base reducer is primarily responsable for routing data from the data source to
      // the view model, and user interactions from the view model to the data source
      Reduce { _, action in
        switch action {
        case let .dataSource(.factsResponse(response)):
          return .send(.viewModel(.newFacts(response.data)))
        case .viewModel(.delegate(.task)):
          return .send(.dataSource(.fetchFacts(count: 40)))
        case .dataSource, .viewModel:
          return .none
        }
      }
    }
  }
}
