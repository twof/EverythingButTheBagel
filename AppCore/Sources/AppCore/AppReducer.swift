import ComposableArchitecture
import EverythingButTheBagelCore
import CatFactsCore
import PictureOfTheDayCore

@Reducer
public struct AppReducer {
  public typealias CatBase = ListFeatureBase<CatFactViewModel, CatFactsResponseModel, EmptyPathReducer>

  @ObservableState
  public struct State: Equatable, Codable {
    public var internetStatus: InternetStatusIndicator.State
    public var errors: ErrorIndicatorViewModel.State
//    public var catFacts: CatBase.State
    public var potd: POTDListAttemptBase.State

    public var path = StackState<Path.State>()

    public init(
      internetStatus: InternetStatusIndicator.State = .init(),
      errors: ErrorIndicatorViewModel.State = .init(),
//      catFacts: CatBase.State = .init(),
      potd: POTDListAttemptBase.State = .init(elements: .loaded(data: [])),
      path: StackState<Path.State> = StackState<Path.State>()
    ) {
      self.internetStatus = internetStatus
      self.errors = errors
//      self.catFacts = catFacts
      self.potd = potd
      self.path = path
    }
  }

  public enum Action {
    case internetStatus(InternetStatusIndicator.Action)
    case errors(ErrorIndicatorViewModel.Action)
//    case catFacts(CatBase.Action)
    case potd(POTDListAttemptBase.Action)

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

      Scope(state: \.potd, action: \.potd) {
        POTDListAttemptBase()
      }

//      Scope(state: \State.catFacts, action: \.catFacts) {
//        CatBase.catFacts.nextPage { response in
//          response.nextPageUrl?.appending(queryItems: [.init(name: "limit", value: "40")])
//        }
//      }

      // TODO: I'm not happy with this error routing setup. It's going to become a huge
      // pain as we add more screens.
      Reduce { _, action in
        switch action {
//        case let .catFacts(.dataSource(.delegate(.error(error, sourceId, errorId)))),
//             let .catFacts(.refreshDataSource(.delegate(.error(error, sourceId, errorId)))):
//          let errorVm = ErrorViewModel(id: errorId, message: error.localizedDescription)
//          return .send(.errors(.newError(sourceId: sourceId, errorVm)))
//
//        case let .catFacts(.dataSource(.delegate(.clearError(sourceId, errorId)))),
//             let .catFacts(.refreshDataSource(.delegate(.clearError(sourceId, errorId)))):
//          return .send(.errors(.clearError(sourceId: sourceId, errorId: errorId)))

        default: return .none
        }
      }.forEach(\.path, action: \.path)
    }
  }
}

extension AppReducer {
  @Reducer(state: .equatable, .codable, action: .equatable)
  public enum Path {
    case catFacts(CatBase)
  }
}
