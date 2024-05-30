import Foundation
import ComposableArchitecture

@Reducer
public struct AsyncImageViewModel {
  @ObservableState
  public struct State: Equatable, Codable {
    public var imageData: Data?

    public init(imageData: Data? = nil) {
      self.imageData = imageData
    }
  }

  public enum Action: Equatable {
    public enum Delegate: Equatable {
      case task
    }

    case delegate(Delegate)
    case newResponse(Data)
  }

  public init() {}

  public var body: some ReducerOf<AsyncImageViewModel> {
    Reduce { state, action in
      switch action {
      case let .newResponse(data):
        state.imageData = data
        return .none
      case .delegate:
        return .none
      }
    }
  }
}
