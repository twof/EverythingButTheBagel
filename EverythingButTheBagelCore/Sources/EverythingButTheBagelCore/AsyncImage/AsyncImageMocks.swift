import Foundation

extension AsyncImageCoordinator.State {
  public static let mock: AsyncImageCoordinator.State = .init(
    imageUrl: URL(string: "example.com/image.jpeg")!,
    imageName: "image.jpeg"
  )
}

extension AsyncImageViewModel.State {
  public static let mock: AsyncImageViewModel.State = AsyncImageCoordinator.State.mock.viewModel
}
