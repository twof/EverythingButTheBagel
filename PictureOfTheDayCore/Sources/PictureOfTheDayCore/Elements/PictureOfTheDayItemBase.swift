import ComposableArchitecture
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayItemBase {
  @ObservableState
  public struct State: Equatable, Codable, Identifiable {
    public var id: String { viewModel.id }
    public var viewModel: PictureOfTheDayItemViewModel.State
    public var asyncImage: AsyncImageBase.State

    public init(title: String, asyncImage: AsyncImageBase.State) {
      self.asyncImage = asyncImage
      self.viewModel = PictureOfTheDayItemViewModel.State(
        title: title
//        , asyncImage: asyncImage.$viewModel
      )
    }

//    private static func casekey<Value>(_ path: CaseKeyPath<PictureOfTheDayItemBase.Action, Value>) -> CaseKeyPath<PictureOfTheDayItemBase.Action, Value> {
//      return path
//    }
  }

  @CasePathable
  public enum Action: Equatable {
    case viewModel(PictureOfTheDayItemViewModel.Action)
    case asyncImage(AsyncImageBase.Action)
  }

//  @Shared var asyncImageScope: Scope<State, Action, AsyncImageBase>

  public init() {
//    let scope = Scope<State, Action, AsyncImageBase>(state: \.asyncImage, action: \.asyncImage) {
//      AsyncImageBase()
//    }
//    self._asyncImageScope = Shared(scope)
  }

  public var body: some ReducerOf<Self> {
    Scope<State, Action, AsyncImageBase>(state: \.asyncImage, action: \.asyncImage) {
      AsyncImageBase()
    }

    Scope(state: \.viewModel, action: \.viewModel) {
      PictureOfTheDayItemViewModel(
//        asyncImageScope: self.$asyncImageScope.
      )
    }

//    ScopeTransformer(from: \.viewModel.asyncImage, to: \.asyncImage.viewModel)

    Reduce { _, action in
      switch action {
      case .asyncImage, .viewModel:
        return .none
      }
    }
  }
}

// @Reducer
// struct ScopeTransformer<Parent: Reducer, Child: Reducer> {
//  let fromAction: AnyCasePath<Parent.Action, Child.Action>
//  let toAction: AnyCasePath<Parent.Action, Child.Action>
//
//  init(
//    fromAction: AnyCasePath<Parent.Action, Child.Action>,
//    toAction: AnyCasePath<Parent.Action, Child.Action>
//  ) {
//    self.fromAction = fromAction
//    self.toAction = toAction
//  }
//
//  var body: some Reducer<Parent.State, Parent.Action> {
//    Reduce { state, action in
//      <#code#>
//    }
//  }
// }

@Reducer
struct ScopableReducer<ParentState, ParentAction, Child: Reducer> {
//  enum StatePath {
//    case casePath(
//      AnyCasePath<ParentState, Child.State>,
//      fileID: StaticString,
//      line: UInt
//    )
//    case keyPath(WritableKeyPath<ParentState, Child.State>)
//  }

  let toChildState: WritableKeyPath<ParentState, Child.State>
  let toChildAction: AnyCasePath<ParentAction, Child.Action>
  let child: Child

  init(
    toChildState: WritableKeyPath<ParentState, Child.State>,
    toChildAction: AnyCasePath<ParentAction, Child.Action>,
    child: Child
  ) {
    self.toChildState = toChildState
    self.toChildAction = toChildAction
    self.child = child
  }

  /// Initializes a reducer that runs the given child reducer against a slice of parent state and
  /// actions.
  ///
  /// Useful for combining child reducers into a parent.
  ///
  /// ```swift
  /// var body: some Reducer<State, Action> {
  ///   Scope(state: \.profile, action: \.profile) {
  ///     Profile()
  ///   }
  ///   Scope(state: \.settings, action: \.settings) {
  ///     Settings()
  ///   }
  ///   // ...
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - toChildState: A writable key path from parent state to a property containing child state.
  ///   - toChildAction: A case path from parent action to a case containing child actions.
  ///   - child: A reducer that will be invoked with child actions against child state.
  @inlinable
  public init(
    state toChildState: WritableKeyPath<ParentState, Child.State>,
    action toChildAction: CaseKeyPath<ParentAction, Child.Action>,
    @ReducerBuilder<Child.State, Child.Action> child: () -> Child
  ) {
    self.init(
      toChildState: toChildState,
      toChildAction: AnyCasePath(toChildAction),
      child: child()
    )
  }

  var body: some Reducer<ParentState, ParentAction> {
    Scope(state: toChildState, action: toChildAction) {
      child
    }
  }
}
