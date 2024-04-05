import ComposableArchitecture

@Reducer
public struct CatFactsListViewModelReducer {
  @ObservableState
  public struct State: Equatable, Codable {
    public var status: Status
//    public var facts: IdentifiedArrayOf<CatFactViewModel> = []
//    public var loading = false
    public var scrollPosition: Double

    public var isLoading: Bool {
      switch status {
      case .loading: true
      case .loaded: false
      }
    }

    public init(
//      facts: IdentifiedArrayOf<CatFactViewModel> = [],
//      loading: Bool = false,
      status: Status = .loaded(data: []),
      scrollPosition: Double = 0.0
    ) {
      //      self.facts = facts
      //      self.loading = loading
      self.scrollPosition = scrollPosition
      self.status = status
    }
  }

  public enum Action: Equatable {
    // The point of delegate actions is to alert parent reducers to some action.
    public enum Delegate: Equatable {
      // In this case, the parent is being alerted that the view did load.
      case task
    }

    case delegate(Delegate)
    case newFacts([CatFactModel])
    case scroll(position: Double)
    case isLoading(Bool)
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newFacts(factModels):
//        state.facts.removeAll()
//        state.facts.append(contentsOf: factModels.map(CatFactViewModel.init(model:)))
        state.status = .loaded(data: factModels.map(CatFactViewModel.init(model:)).toIdentifiedArray)
        return .none
      case let .scroll(position):
        state.scrollPosition = position
        return .none
      case let .isLoading(isLoading):
        let data = switch state.status {
        case let .loaded(data): data
        case let .loading(data, _): data
        }

        state.status = isLoading
          ? .loading(data: data, placeholders: .placeholders)
          : .loaded(data: data)
        return .none
      case .delegate:
        return .none
      }
    }
  }
}

public enum Status: Codable, Equatable {
  case loading(data: IdentifiedArrayOf<CatFactViewModel>, placeholders: IdentifiedArrayOf<CatFactViewModel>)
  case loaded(data: IdentifiedArrayOf<CatFactViewModel>)
}

extension Status {
  public var data: IdentifiedArrayOf<CatFactViewModel> {
    switch self {
    case let .loaded(data): data
    case let .loading(data, _): data
    }
  }

  public var placeholders: IdentifiedArrayOf<CatFactViewModel> {
    switch self {
    case .loaded: []
    case let .loading(_, placeholders): placeholders
    }
  }

  public var factsList: IdentifiedArrayOf<CatFactViewModel> {
    // Return a list of data + placeholders up to 20 elements
    (self.data + self.placeholders.suffix(max(0, 20 - self.data.count)))
  }
}

public struct CatFactViewModel: Codable, Equatable, Identifiable {
  public var id: String { fact }
  public let fact: String

  public init(model: CatFactModel) {
    self.fact = model.fact
  }

  public init(fact: String) {
    self.fact = fact
  }
}

extension CatFactViewModel {
  public static let placeholders = (0..<20).map {
    CatFactViewModel(fact: "Example of a long fact Example of a long fact Example of a long fact Example of a long fact Example of a long fact Example of a long fact Example of a long fact Example of a long fact \($0)")
  }
}

extension IdentifiedArrayOf<CatFactViewModel> {
  public static let placeholders = CatFactViewModel.placeholders.toIdentifiedArray
}
