import ComposableArchitecture
import Foundation

@Reducer
public struct ErrorIndicatorViewModel {
  @ObservableState
  public struct State: Equatable, Codable {
    /// Source IDs to list of errors
    ///
    /// Used to indicate active errors produced by other reducers
    public var errors: [String: IdentifiedArrayOf<ErrorViewModel>]

    public init(errors: [String: IdentifiedArrayOf<ErrorViewModel>] = [:]) {
      self.errors = errors
    }

    /// `keys` indicate error sources to look for. If `keys` is empty, it will look for errors from any sources.
    public func error(forKeys keys: [String] = []) -> ErrorViewModel? {
      if keys.isEmpty {
        return errors.values.lazy.flatMap { $0 }.first
      }

      return keys.lazy.compactMap { errors[$0] }.flatMap { $0 }.first
    }
  }

  public enum Action: Equatable {
    case newError(sourceId: String, ErrorViewModel)
    case clearError(sourceId: String, ErrorViewModel)
  }

  public init() {}

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

public struct ErrorViewModel: Codable, Equatable, Identifiable {
  public let id: UUID
  public let message: String

  public init(id: UUID, message: String) {
    self.id = id
    self.message = message
  }
}
