import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import UIKit

public struct AsyncImageLoader: View {
  let store: StoreOf<AsyncImageViewModel>

  public init(store: StoreOf<AsyncImageViewModel>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      if let imageData = store.imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
      }
    }.task {
      print("task")
      await store.send(.delegate(.task)).finish()
    }
  }
}
