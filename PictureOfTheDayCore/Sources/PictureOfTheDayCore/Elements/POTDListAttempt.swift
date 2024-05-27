import ComposableArchitecture
import EverythingButTheBagelCore

@Reducer
public struct ElementsBase {
  public struct State: Codable, Equatable {
    public var elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>

    public init(elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>) {
      self.elements = elements
    }
  }

  @CasePathable
  public enum Action: Equatable {
    case element(IdentifiedActionOf<PictureOfTheDayItemBase>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      return .none
    }.forEach(\.elements, action: \.element) {
      PictureOfTheDayItemBase()
    }
  }
}

@Reducer
public struct POTDListAttemptBase {
  @ObservableState
  public struct State: Codable, Equatable {
    public var elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>

    public init(elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>) {
      self.elements = elements
    }
  }

  public enum Action: Equatable {
    case element(IdentifiedActionOf<PictureOfTheDayItemBase>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      return .none
    }.forEach(\.elements, action: \.element) {
      PictureOfTheDayItemBase()
    }
  }
}

@Reducer
public struct POTDListAttemptVM {
  @ObservableState
  public struct State: Codable, Equatable {

  }

  public enum Action: Equatable {

  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
  }
}
