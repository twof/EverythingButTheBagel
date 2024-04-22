import ComposableArchitecture

@Reducer
public struct AppReducer {
  @ObservableState
  public struct State: Equatable, Codable {
    public var internetStatus: InternetStatusIndicator.State
    public var errors: ErrorIndicatorViewModel.State
    public var catFacts: CatFactsListBase.State

    public var path = StackState<Path.State>()

    public init(
      internetStatus: InternetStatusIndicator.State = .init(),
      errors: ErrorIndicatorViewModel.State = .init(),
      catFacts: CatFactsListBase.State = .init(),
      path: StackState<Path.State> = StackState<Path.State>()
    ) {
      self.internetStatus = internetStatus
      self.errors = errors
      self.catFacts = catFacts
      self.path = path
    }
  }

  public enum Action {
    case internetStatus(InternetStatusIndicator.Action)
    case errors(ErrorIndicatorViewModel.Action)
    case catFacts(CatFactsListBase.Action)

    case path(StackAction<Path.State, Path.Action>)
  }

  public init() { }

  public var body: some Reducer<State, Action> {
    CombineReducers {
      Scope(state: \State.internetStatus, action: \.internetStatus) {
        InternetStatusIndicator()
      }

      Scope(state: \State.errors, action: \.errors) {
        ErrorIndicatorViewModel()
      }

      Scope(state: \State.catFacts, action: \.catFacts) {
        CatFactsListBase()
      }

      Reduce { _, action in
        switch action {
        case let .catFacts(.dataSource(.delegate(.error(error, sourceId, errorId)))):
          let errorVm = ErrorViewModel(id: errorId, message: error.localizedDescription)
          return .send(.errors(.newError(sourceId: sourceId, errorVm)))

        default: return .none
        }

        return .none
      }.forEach(\.path, action: \.path)
    }
  }
}

extension AppReducer {
  @Reducer(state: .equatable, .codable, action: .equatable)
  public enum Path {
    case catFacts(CatFactsListBase)
  }
}
