import Foundation
import ComposableArchitecture

@Reducer
public struct AsyncImageViewModel {
  @ObservableState
  public struct State: Equatable, Codable {
    public var imageData: Data?
    public var isLoading: Bool = false

    public init(imageData: Data? = nil, isLoading: Bool) {
      self.imageData = imageData
      self.isLoading = isLoading
    }
  }

  public enum Action: Equatable {
    public enum Delegate: Equatable {
      case task
    }

    case delegate(Delegate)
    case newResponse(Data)
    case isLoading(Bool)
  }

  public init() {}

  public var body: some ReducerOf<AsyncImageViewModel> {
    Reduce { state, action in
      switch action {
      case let .isLoading(isLoading):
        state.isLoading = isLoading
        return .none
      case let .newResponse(data):
        state.imageData = data
        return .none
      case .delegate:
        return .none
      }
    }
  }
}
