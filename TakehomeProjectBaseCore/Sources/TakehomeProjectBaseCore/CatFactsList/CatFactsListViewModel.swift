import ComposableArchitecture

@Reducer
public struct CatFactsListViewModelReducer {
  @ObservableState
  public struct State: Equatable, Codable {
    public var facts: IdentifiedArrayOf<CatFactViewModel> = []
    public var loading = false
    public var scrollPosition: Float = 0.0
    
    public init(
      facts: IdentifiedArrayOf<CatFactViewModel> = [],
      loading: Bool = false,
      scrollPosition: Float = 0.0
    ) {
      self.facts = facts
      self.loading = loading
      self.scrollPosition = scrollPosition
    }
  }
  
  public enum Action: Equatable {
    case task
    case newFacts([CatFactModel])
    case scroll(position: Float)
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
      case let .scroll(position):
        state.scrollPosition = position
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


