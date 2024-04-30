import ComposableArchitecture

@Reducer(state: .codable, .equatable, action: .equatable)
public enum EmptyPathReducer {
  case none
}
