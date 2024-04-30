import ComposableArchitecture
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayDetailVM {
  @ObservableState
  public struct State: Codable, Equatable {
    public var title: String
    public var description: String
//    public var asyncImage: AsyncImageViewModel.State

    public init(
      title: String,
      description: String
//      ,
//      asyncImage: AsyncImageViewModel.State
    ) {
      self.title = title
      self.description = description
//      self.asyncImage = asyncImage
    }
  }

  public enum Action: Equatable {
    case asyncImage(AsyncImageViewModel.Action)
  }

  public init() {}

  public var body: some ReducerOf<PictureOfTheDayDetailVM> {
    CombineReducers {
//      Scope(state: \.asyncImage, action: \.asyncImage) {
//        AsyncImageViewModel()
//      }

      Reduce { _, _ in
        return .none
      }
    }
  }
}
