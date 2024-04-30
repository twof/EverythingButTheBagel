import ComposableArchitecture
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayDetailBase {
  @ObservableState
  public struct State: Codable, Equatable {
    public var asyncImage: AsyncImageBase.State
    public var viewModel: PictureOfTheDayDetailVM.State

    public init(asyncImage: AsyncImageBase.State, viewModel: PictureOfTheDayDetailVM.State) {
      self.asyncImage = asyncImage
      self.viewModel = viewModel
    }
  }

  public enum Action: Equatable {
    case asyncImage(AsyncImageBase.Action)
    case viewModel(PictureOfTheDayDetailVM.Action)
  }

  public init() {}

  public var body: some ReducerOf<PictureOfTheDayDetailBase> {
    CombineReducers {
      Scope(state: \.asyncImage, action: \.asyncImage) {
        AsyncImageBase()
      }

      Scope(state: \.viewModel, action: \.viewModel) {
        PictureOfTheDayDetailVM()
      }

      Reduce { _, _ in
        return .none
      }
    }
  }
}
