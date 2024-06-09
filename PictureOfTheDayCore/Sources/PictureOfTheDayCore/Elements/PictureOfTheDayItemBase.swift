import ComposableArchitecture
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayItemBase {
  @ObservableState
  public struct State: Equatable, Codable, Identifiable {
    public var id: String { viewModel.id }
    public var viewModel: PictureOfTheDayItemViewModel.State
    public var asyncImage: AsyncImageCoordinator.State

    public init(title: String, asyncImage: AsyncImageCoordinator.State) {
      self.asyncImage = asyncImage
      self.viewModel = PictureOfTheDayItemViewModel.State(
        title: title
      )
    }
  }

  @CasePathable
  public enum Action: Equatable {
    case viewModel(PictureOfTheDayItemViewModel.Action)
    case asyncImage(AsyncImageCoordinator.Action)
  }

  public init() { }

  public var body: some ReducerOf<Self> {
    Scope(state: \.asyncImage, action: \.asyncImage) {
      AsyncImageCoordinator()
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
