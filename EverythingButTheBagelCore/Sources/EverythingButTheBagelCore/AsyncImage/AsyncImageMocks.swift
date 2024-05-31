import Foundation

extension AsyncImageBase.State {
  public static let mock: AsyncImageBase.State = .init(imageUrl: URL(string: "example.com/image.jpeg")!)
}

extension AsyncImageViewModel.State {
  public static let mock: AsyncImageViewModel.State = AsyncImageBase.State.mock.viewModel
}
