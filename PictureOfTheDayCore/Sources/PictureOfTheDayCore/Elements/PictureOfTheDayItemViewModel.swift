import EverythingButTheBagelCore
import Foundation
import IdentifiedCollections
import ComposableArchitecture

@Reducer
public struct PictureOfTheDayItemViewModel {
  @ObservableState
  public struct State: Codable, Equatable, Identifiable, Sendable {
    public var id: String { title }
    public let title: String

    public init(
      title: String
    ) {
      self.title = title
    }
  }

  public enum Action: Equatable {
    @CasePathable
    public enum Delegate: Equatable {
      case didTap
      case didAppear
    }

    case delegate(Delegate)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
