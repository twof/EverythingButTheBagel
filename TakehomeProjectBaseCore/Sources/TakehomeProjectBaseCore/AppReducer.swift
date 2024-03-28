import ComposableArchitecture

@Reducer
public struct AppReducer {
  @ObservableState
  public struct State: Equatable {
    var internetStatus: InternetStatusIndicator.State
    var errors: ErrorIndicatorViewModel.State
    var catFacts: CatFactsListBase.State
  }
  
  public enum Action {
    case internetStatus(InternetStatusIndicator.Action)
    case errors(ErrorIndicatorViewModel.Action)
    case catFacts(CatFactsListBase.Action)
  }
  
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
      
      Reduce { state, action in
//        switch action {
//        case let .catFacts(.dataSource(.error(error))):
//          let errorVm = ErrorViewModel(id: <#T##String#>, message: <#T##String#>)
//          return .send(.errors(.newError(sourceId: CatFactsListDataSource.errorId, )))
//        }
        
        return .none
      }
    }
  }
}

/// Conformance indicates a type produces an error tracked by ErrorIndicatorViewModel which requires a `sourceId`
protocol ErrorProducer {
  static var errorId: String { get }
}
