import ComposableArchitecture

// swiftlint:disable opening_brace
@Reducer
public struct ListFeatureViewModelReducer<
  ViewModel: Codable & Equatable & Identifiable & ViewModelPlaceholders,
  PathReducer: CaseReducer
> where
  PathReducer.Action: Equatable,
  PathReducer.State: Equatable & Codable & CaseReducerState & ObservableState,
  PathReducer.State.StateReducer.Action == PathReducer.Action
{
  // swiftlint:enable opening_brace
  @ObservableState
  public struct State: Equatable, Codable, ListViewModelState {
    public let emptyListMessage: LocalizedTextState

    public var status: ListViewModelStatus<ViewModel>
    public var scrollPosition: Double

    public var path: StackState<PathReducer.State>

    public init(
      status: ListViewModelStatus<ViewModel> = .init(data: [], placeholders: [], isLoading: false),
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
    case navigateToPath(PathReducer.State)
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newResponse(response, strategy):
        let newVms = response.toIdentifiedArray
        switch strategy {
        case .append:
          state.status.append(contentsOf: newVms.elements)
//          state.status = .loaded(data: state.status.data + newVms)
        case .reset:
          state.status.data = newVms
//          state.status = .loaded(data: newVms)
        }

        return .none

      case let .scroll(position):
        state.scrollPosition = position
        return .none

      case let .isLoading(isLoading):
        state.status.isLoading = isLoading
        return .none

      case let .navigateToPath(path):
        state.path.append(path)
        return .none

      case .delegate, .path:
        return .none
      }
    }.forEach(\.path, action: \.path) {
      PathReducer.State.StateReducer.body
    }
  }
}
