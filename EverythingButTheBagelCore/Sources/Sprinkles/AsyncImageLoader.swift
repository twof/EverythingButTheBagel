import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import UIKit
import GiphyUISDK

/// Replacement for `SwiftUI.AsyncImage` created to offer more control
///
/// `SwiftUI.AsyncImage` had several bugs at the time of creation eg images would never load if the initial
/// load was cancelled which would happen sometimes in a list where earlier images loading would push later
/// images offscreen, canceling their request
public struct AsyncImageLoader: View {
  var store: StoreOf<AsyncImageViewModel>
//  @State var imageView: AnyView?

  public init(store: StoreOf<AsyncImageViewModel>) {
    self.store = store
  }

  public var body: some View {
    // swiftlint:disable:next redundant_discardable_let
    let _ = Self._printChanges()
    store.imageView
    .task {
      // Start loading image
      await store.send(.delegate(.task)).finish()
    }
    .task(id: store.imageData, priority: .background) {
//      // Only set up the image once
//      guard imageView == nil else { return }
//      // We create the imageView on a background thread because UIImage does an expensive
//      // decoding path.
//      // See: WWDC 2019 Image and Graphics Best Practices
//      let imageView = store.imageView
//      await MainActor.run {
//        self.imageView = AnyView(imageView)
//      }
    }
    .onDisappear {
      // Alert reducer that image is no longer needed so it can clean up expensive resources
      store.send(.delegate(.disappear))
    }
  }
}

public extension AsyncImageLoader {
  /// Mock view used in previews isn't loading and displays no image
  static var mock = AsyncImageLoader(
    store: Store(
      initialState: AsyncImageViewModel.State(imageName: "", isLoading: false),
      reducer: { AsyncImageViewModel() }
    )
  )
}

extension AsyncImageViewModel.State {
  /// Image to display bsed on the `AsyncImageViewModel.State`
  @ViewBuilder fileprivate var imageView: some View {
    if let imageType {
      switch imageType {
      case let .animatedGif(url):
        GiphyAnimatedImageView(url: url)
      case .staticImage:
        imageData.map {
          Image(uiImage: $0)
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
      }
    }
  }
}

/// Shimmer view to indicate loading
struct LoadingImage: View {
  var body: some View {
    Rectangle()
      .foregroundStyle(Color.gray.opacity(0.7))
      .redacted(reason: .placeholder)
      .shimmering(bandSize: 10)
      .accessibilityLabel("Image Loading")
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
  let store = Store(
    initialState: AsyncImageCoordinator.State(
      imageUrl: url,
      imageName: "Ryugu01_Rover1aHayabusa2_960.jpg"
    )
  ) {
    AsyncImageCoordinator()
  }

  let gifURL = URL(string: "https://apod.nasa.gov/apod/image/stareggs_hst_big.gif")!
  let gifStore = Store(
    initialState: AsyncImageCoordinator.State(
      imageUrl: gifURL,
      imageName: "stareggs_hst_big.gif"
    )
  ) {
    AsyncImageCoordinator()
  }

  return Group {
    AsyncImageLoader(store: store.scope(state: \.viewModel, action: \.viewModel))
      .frame(width: 200, height: 200)
    AsyncImageLoader(store: gifStore.scope(state: \.viewModel, action: \.viewModel))
      .frame(width: 200, height: 200)
  }
}
