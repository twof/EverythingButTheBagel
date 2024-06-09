import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import UIKit
import GiphyUISDK

public struct AsyncImageLoader: View, Equatable {
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
  var imageView: AnyView? {
    switch self {
    case let .animatedGif(url):
      return AnyView(GiphyAnimatedImageView(url: url))
    case let .staticImage(url):
      print("loading image from disk \(url.lastPathComponent)")
      return url.localImage.map {
        AnyView(
          Image(uiImage: $0)
          .resizable()
          .aspectRatio(contentMode: .fit)
        )
      }
    }
  }
}

extension URL {
  var localImage: UIImage? {
    (try? Data(contentsOf: self)).flatMap { UIImage(data: $0) }
  }
}

// Live
#Preview {
  let url = URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!
  let store = Store(initialState: AsyncImageCoordinator.State(imageUrl: url, imageName: "Ryugu01_Rover1aHayabusa2_960.jpg")) {
    AsyncImageCoordinator()
  }

  let gifURL = URL(string: "https://apod.nasa.gov/apod/image/stareggs_hst_big.gif")!

  let gifStore = Store(initialState: AsyncImageCoordinator.State(imageUrl: gifURL, imageName: "stareggs_hst_big.gif")) {
    AsyncImageCoordinator()
  }

  return Group {
    AsyncImageLoader(store: store.scope(state: \.viewModel, action: \.viewModel))
      .frame(width: 200, height: 200)
    AsyncImageLoader(store: gifStore.scope(state: \.viewModel, action: \.viewModel))
      .frame(width: 200, height: 200)
  }
}
