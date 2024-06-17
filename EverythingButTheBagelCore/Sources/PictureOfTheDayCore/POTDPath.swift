import ComposableArchitecture

@Reducer(state: .codable, .equatable, action: .equatable)
public enum POTDPath {
  case detail(PictureOfTheDayDetailBase)
}
