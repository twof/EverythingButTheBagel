import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import UIKit
import GiphyUISDK

public struct AsyncImageLoader: View {
  var store: StoreOf<AsyncImageViewModel>
  @State var imageView: AnyView?

  public init(store: StoreOf<AsyncImageViewModel>) {
    self.store = store
  }

  public var body: some View {
    Group {
      if let imageView {
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
      print("task")
      await store.send(.delegate(.task)).finish()
    }
    .task(id: store.imageData, priority: .background) {
      // Only set up the image once
      guard imageView == nil else { return }
      // We create the imageView on a background thread because UIImage does an expensive
      // decoding path.
      // See: WWDC 2019 Image and Graphics Best Practices
      let imageView = store.imageView
      await MainActor.run {
        self.imageView = imageView
      }
    }
    .onDisappear {
      store.send(.delegate(.disappear))
    }
  }
}

public extension AsyncImageLoader {
  static var mock = AsyncImageLoader(store: Store(initialState: AsyncImageViewModel.State(imageName: "", isLoading: false), reducer: { AsyncImageViewModel() }))
}

extension AsyncImageViewModel.State {
  var imageView: AnyView? {
    guard let imageType, let imageData else { return nil }

    switch imageType {
    case let .animatedGif(url):
      return AnyView(GiphyAnimatedImageView(url: url))
    case let .staticImage(url):
      print("loading image from disk \(url.lastPathComponent)")
      guard let uiImage = UIImage(data: imageData) else { return nil }

      return AnyView(
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
      )
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
