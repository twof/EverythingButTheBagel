import ComposableArchitecture

@Reducer
public struct ListFeatureViewModelReducer<
  ViewModel: Codable & Equatable & Identifiable & ViewModelPlaceholders,
  PathReducer: CaseReducer
> where
PathReducer.Action: Equatable,
PathReducer.State: Equatable & Codable & CaseReducerState & ObservableState,
PathReducer.State.StateReducer.Action == PathReducer.Action {
  @ObservableState
  public struct State: Equatable, Codable, ListViewModelState {
    public let emptyListMessage: LocalizedTextState

    public var status: ListViewModelStatus<ViewModel>
    public var scrollPosition: Double

    public var path: StackState<PathReducer.State>

    public var isLoading: Bool {
      switch status {
      case .loading: true
      case .loaded: false
      }
    }

    public init(
      status: ListViewModelStatus<ViewModel> = .loaded(data: []),
      scrollPosition: Double = 0.0,
      emptyListMessage: LocalizedTextState,
      path: StackState<PathReducer.State> = .init()
    ) {
      self.scrollPosition = scrollPosition
      self.status = status
      self.emptyListMessage = emptyListMessage
      self.path = path
    }

    enum CodingKeys: CodingKey {
      // swiftlint:disable:next identifier_name
      case _status
      // swiftlint:disable:next identifier_name
      case _scrollPosition
      case emptyListMessage
      // swiftlint:disable:next identifier_name
      case _path
    }
  }

  public enum Action: Equatable, ListViewModelAction {
    case delegate(ListViewModelDelegate<ViewModel.ID>)
    case newResponse([ViewModel], strategy: NewResponseStrategy = .append)
    case scroll(position: Double)
    case isLoading(Bool)
    case path(StackActionOf<PathReducer>)
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newResponse(response, strategy):
        let newVms = response.toIdentifiedArray
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

      case .delegate, .path:
        return .none
      }
    }.forEach(\.path, action: \.path) {
      PathReducer.State.StateReducer.body
    }
  }
}
