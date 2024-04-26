import ComposableArchitecture

public protocol ViewModelPlaceholders {
  static var placeholders: [Self] { get }
}

extension IdentifiedArrayOf where Element: ViewModelPlaceholders & Identifiable {
  static var placeholders: IdentifiedArrayOf<Element> {
    Element.placeholders.toIdentifiedArray
  }
}

@Reducer
public struct ListFeatureViewModelReducer<
  ViewModel: Codable & Equatable & Identifiable & ViewModelPlaceholders,
  ResponseType: Codable & Equatable
> {
  @ObservableState
  public struct State: Equatable, Codable, ListViewModelState {
    public let emptyListMessage: LocalizedTextState

    public var status: ListViewModelStatus<ViewModel>
    public var scrollPosition: Double

    public var isLoading: Bool {
      switch status {
      case .loading: true
      case .loaded: false
      }
    }

    public init(
      status: ListViewModelStatus<ViewModel> = .loaded(data: []),
      scrollPosition: Double = 0.0,
      emptyListMessage: LocalizedTextState
    ) {
      self.scrollPosition = scrollPosition
      self.status = status
      self.emptyListMessage = emptyListMessage
    }

    enum CodingKeys: CodingKey {
      // swiftlint:disable:next identifier_name
      case _status
      // swiftlint:disable:next identifier_name
      case _scrollPosition
      case emptyListMessage
    }
  }

  public enum Action: Equatable, ListViewModelAction {
    case delegate(ListViewModelDelegate)
    case newResponse(ResponseType, strategy: NewResponseStrategy = .append)
    case scroll(position: Double)
    case isLoading(Bool)
  }

  let viewModelGenerator: (ResponseType) -> [ViewModel]

  public init(viewModelGenerator: @escaping (ResponseType) -> [ViewModel]) {
    self.viewModelGenerator = viewModelGenerator
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newResponse(response, strategy):
        let newVms = viewModelGenerator(response).toIdentifiedArray
        switch strategy {
        case .append:
          state.status = .loaded(data: state.status.data + newVms)
        case .reset:
          state.status = .loaded(data: newVms)
        }

        return .none

      case let .scroll(position):
        state.scrollPosition = position
        return .none

      case let .isLoading(isLoading):
        let data = state.status.data

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
