import ComposableArchitecture
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayDetailVM {
  @ObservableState
  public struct State: Codable, Equatable {
    public var title: String
    public var description: String

    public init(
      title: String,
      description: String
    ) {
      self.title = title
      self.description = description
    }
  }

  public enum Action: Equatable {}

  public init() {}

  public var body: some ReducerOf<PictureOfTheDayDetailVM> {
    EmptyReducer()
  }
}
