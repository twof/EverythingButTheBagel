import ComposableArchitecture

public struct ErrorViewModel: Codable, Equatable, Identifiable {
  public let id: String
  public let message: String
}

@Reducer
public struct ErrorIndicatorViewModel {
  public struct State: Equatable, Codable {
    /// Source IDs to list of errors
    ///
    /// Used to indicate active errors produced by other reducers
    public var errors: [String: IdentifiedArrayOf<ErrorViewModel>]
  }
  
  public enum Action: Equatable {
    case newError(sourceId: String, ErrorViewModel)
    case clearError(sourceId: String, ErrorViewModel)
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newError(sourceId, error):
        state.errors[sourceId, default: []].append(error)
        return .none
      case let .clearError(sourceId, error):
        state.errors[sourceId]?.remove(error)
        return .none
      }
    }
  }
}
