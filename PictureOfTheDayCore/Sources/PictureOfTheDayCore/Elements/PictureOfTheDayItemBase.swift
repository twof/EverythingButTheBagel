import ComposableArchitecture
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayItemBase {
  @ObservableState
  public struct State: Equatable, Codable, Identifiable {
    public var id: String { viewModel.id }
    public var viewModel: PictureOfTheDayItemViewModel.State
    public var asyncImage: AsyncImageBase.State

    public init(title: String, asyncImage: AsyncImageBase.State) {
      self.asyncImage = asyncImage
      self.viewModel = PictureOfTheDayItemViewModel.State(
        title: title
      )
    }
  }

  @CasePathable
  public enum Action: Equatable {
    case viewModel(PictureOfTheDayItemViewModel.Action)
    case asyncImage(AsyncImageBase.Action)
  }

  public init() { }

  public var body: some ReducerOf<Self> {
    Scope<State, Action, AsyncImageBase>(state: \.asyncImage, action: \.asyncImage) {
      AsyncImageBase()
    }

    Scope(state: \.viewModel, action: \.viewModel) {
      PictureOfTheDayItemViewModel()
    }

    Reduce { _, action in
      switch action {
      case .asyncImage, .viewModel:
        return .none
      }
    }
  }
}
