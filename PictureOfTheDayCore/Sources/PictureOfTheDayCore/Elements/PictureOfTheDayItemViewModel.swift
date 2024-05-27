import EverythingButTheBagelCore
import Foundation
import IdentifiedCollections
import ComposableArchitecture

@Reducer
public struct PictureOfTheDayItemViewModel {
  @ObservableState
  public struct State: Codable, Equatable, Identifiable {
    public var id: String { title }
    public let title: String

    public init(
      title: String
    ) {
      self.title = title
    }
  }

  public enum Action: Equatable {}

  public init() {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
