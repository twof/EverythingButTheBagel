import ComposableArchitecture

@Reducer
public struct CatFactsListViewModelReducer {
  @ObservableState
  public struct State: Equatable, Codable {
    public var facts: IdentifiedArrayOf<CatFactViewModel> = []
    public var loading = false
    public var scrollPosition: Scroll.State

    public init(
      facts: IdentifiedArrayOf<CatFactViewModel> = [],
      loading: Bool = false,
      scrollPosition: Scroll.State = .init()
    ) {
      self.facts = facts
      self.loading = loading
      self.scrollPosition = scrollPosition
    }
  }

  public enum Action: Equatable {
    case task
    case newFacts([CatFactModel])
    case scroll(Scroll.Action)

  }

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .none
      case let .newFacts(factModels):
        state.facts.removeAll()
        state.facts.append(contentsOf: factModels.map(CatFactViewModel.init(model:)))
        return .none
      case .scroll:
        return .none
      }
    }
  }
}

public struct CatFactViewModel: Codable, Equatable, Identifiable {
  public var id: String { fact }
  public let fact: String

  public init(model: CatFactModel) {
    self.fact = model.fact
  }
}
