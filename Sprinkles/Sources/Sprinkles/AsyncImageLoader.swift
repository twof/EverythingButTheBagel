import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import UIKit
import GiphyUISDK

public struct AsyncImageLoader: View {
  var store: StoreOf<AsyncImageViewModel>

  public init(store: StoreOf<AsyncImageViewModel>) {
    self.store = store
  }

  public var body: some View {
    Group {
      if
        let imageType = store.imageType,
        let imageView = imageType.imageView
      {
        imageView
      } else {
        Rectangle()
          .foregroundStyle(Color.gray.opacity(0.7))
          .redacted(reason: .placeholder)
          .shimmering(bandSize: 10)
          .accessibilityLabel("Image Loading")
      }
    }
    .task {
      await store.send(.delegate(.task)).finish()
    }
  }
}

public extension AsyncImageLoader {
  static var mock = AsyncImageLoader(store: Store(initialState: AsyncImageViewModel.State(imageName: "", isLoading: false), reducer: { AsyncImageViewModel() }))
}

extension ImageType {
  @ViewBuilder var imageView: (some View)? {
    switch self {
    case let .animatedGif(url):
      GiphyAnimatedImageView(url: url)
    case let .staticImage(data):
      UIImage(data: data).map {
        Image(uiImage: $0)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 100, height: 100)
      }
    }
  }
}

// Live
#Preview {
  let url = URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!
  let store = Store(initialState: AsyncImageCoordinator.State(imageUrl: url, imageName: "Ryugu01_Rover1aHayabusa2_960.jpg")) {
    AsyncImageCoordinator()
  }

  return AsyncImageLoader(store: store.scope(state: \.viewModel, action: \.viewModel))
    .frame(width: 200, height: 200)
}

// Loading
#Preview {
  AsyncImageLoader(store: Store(initialState: AsyncImageViewModel.State(imageName: "test.gif", isLoading: true), reducer: {
    AsyncImageViewModel()
  }))
  .frame(width: 200, height: 200)
}
