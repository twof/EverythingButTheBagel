import ComposableArchitecture
import SwiftUI

@Reducer
public struct Scroll {
  @ObservableState
  public struct State: Codable, Equatable {
    public var tracker: ScrollTrackerReducer.State
    public var trackerId: String?

    public init(tracker: ScrollTrackerReducer.State = .init(), trackerId: String? = nil) {
      self.tracker = tracker
      self.trackerId = trackerId
    }
  }

  public enum Action: Equatable {
    case tracker(ScrollTrackerReducer.Action)
    case scrollToPosition(Double)
    case setTracker(String?)
  }

  let trackerId: String

  public init(trackerId: String) {
    self.trackerId = trackerId
  }

  public var body: some ReducerOf<Self> {
    CombineReducers {
      Scope(state: \.tracker, action: \.tracker) {
        ScrollTrackerReducer()
      }

      Reduce { state, action in
        switch action {
        case let .scrollToPosition(position):
          print("scroll to position")
          let transaction = Transaction()

          return .run { send in
            await send(.setTracker(nil))
            await send(.tracker(.jump(position: position)))
            await send(.setTracker(trackerId))
          }
          .transaction(transaction)
        case let .setTracker(tracker):
          print("new id", tracker)
          state.trackerId = tracker
          return .none

        case .tracker:
          return .none
        }
      }
    }
  }
}

@Reducer
public struct ScrollTrackerReducer {
  @ObservableState
  public struct State: Codable, Equatable {
    public var totalOffset: Double = 0.0

    public init(totalOffset: Double = 0.0) {
      self.totalOffset = totalOffset
    }
  }

  public enum Action: Equatable {
    case scroll(position: Double)
    case jump(position: Double)
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .scroll(position):
        print("position", position)
        state.totalOffset = position
        return .none
      case let .jump(position):
        print("jump", position)
        state.totalOffset = position
        return .none
      }
    }
  }
}
