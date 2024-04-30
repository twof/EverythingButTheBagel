import ComposableArchitecture

// @Reducer
// public struct ChildListFeatureVMReducer<
//  ViewModel: Codable & Equatable & Identifiable & ViewModelPlaceholders,
//  ResponseType: Codable & Equatable,
//  PathReducer: CaseReducer
// > where
//  PathReducer.Action: Equatable,
//  PathReducer.State: Equatable & Codable & CaseReducerState & ObservableState,
//  PathReducer.State.StateReducer.Action == PathReducer.Action {
//
//  public typealias ListType = ListFeatureViewModelReducer<ViewModel>
//
//  @ObservableState
//  public struct State: Equatable, Codable, ListViewModelState {
//    public var list: ListType.State
//    public var path: StackState<PathReducer.State>
//
//    public var status: ListViewModelStatus<ViewModel> {
//      get { list.status }
//      set { list.status = newValue }
//    }
//
//    public var scrollPosition: Double {
//      get { list.scrollPosition }
//      set { list.scrollPosition = newValue }
//    }
//
//    public init(
//      list: ListType.State,
//      path: StackState<PathReducer.State> = .init()
//    ) {
//      self.list = list
//      self.path = path
//    }
//  }
//
//  public enum Action: Equatable, ListViewModelAction {
//    public enum Delegate: Equatable {
//      case rowTapped(ViewModel.ID)
//    }
//
//    case list(ListType.Action)
//    case path(StackActionOf<PathReducer>)
//
//    public static func newResponse(
//      _ vms: [ViewModel],
//      strategy: NewResponseStrategy
//    ) -> ChildListFeatureVMReducer<ViewModel, ResponseType, PathReducer>.Action {
//      .list(.newResponse(vms, strategy: strategy))
//    }
//
//    public static func delegate(
//      _ delegate: ListViewModelDelegate<ViewModel.ID>
//    ) -> ChildListFeatureVMReducer<ViewModel, ResponseType, PathReducer>.Action {
//      .list(.delegate(delegate))
//    }
//
//    public static func scroll(position: Double) -> ChildListFeatureVMReducer<ViewModel, ResponseType, PathReducer>.Action {
//      .list(.scroll(position: position))
//    }
//
//    public static func isLoading(_ isLoading: Bool) -> ChildListFeatureVMReducer<ViewModel, ResponseType, PathReducer>.Action {
//      .list(.isLoading(isLoading))
//    }
//  }
//
//  let viewModelGenerator: (ResponseType) -> [ViewModel]
//
//  public init(
//    viewModelGenerator: @escaping (ResponseType) -> [ViewModel]
//  ) {
//    self.viewModelGenerator = viewModelGenerator
//  }
//
//  public var body: some ReducerOf<Self> {
//    CombineReducers {
//      Scope(state: \.list, action: \.list) {
//        ListType()
//      }
//
//      Reduce { _, action in
//        switch action {
//
//        case .list, .path:
//          return .none
//        }
//      }
//    }.forEach(\.path, action: \.path) {
//      PathReducer.State.StateReducer.body
//    }
//  }
// }
