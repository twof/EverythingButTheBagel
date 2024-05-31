import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import UIKit

public struct AsyncImageLiveView: View {
  let store: StoreOf<AsyncImageBase>

  public var body: some View {
    AsyncImageLoader(store: store.scope(state: \.viewModel, action: \.viewModel))
  }
}

public struct AsyncImageLoader: View {
  let store: StoreOf<AsyncImageViewModel>

  public init(store: StoreOf<AsyncImageViewModel>) {
    self.store = store
  }

  public var body: some View {
    if let data = store.imageData, let image = UIImage(data: data) {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fit)
    } else {
      Rectangle()
        .foregroundStyle(Color.gray.opacity(0.7))
        .redacted(reason: .placeholder)
        .shimmering(bandSize: 10)
        .accessibilityLabel("Image Loading")
        .task {
          await store.send(.delegate(.task)).finish()
        }
    }
  }
}

public extension AsyncImageLoader {
  static let placeholder: some View = mock
    .redacted(reason: .placeholder)
    .shimmering()
    .accessibilityLabel("Loading")

  static let mock = AsyncImageLoader(store: .init(initialState: AsyncImageViewModel.State(), reducer: { AsyncImageViewModel() }))
}

#Preview {
  let url = URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!
  let store = Store(initialState: AsyncImageBase.State(imageUrl: url)) {
    AsyncImageBase()
  }

  return AsyncImageLoader(store: store.scope(state: \.viewModel, action: \.viewModel))
    .frame(width: 200, height: 200)
}
