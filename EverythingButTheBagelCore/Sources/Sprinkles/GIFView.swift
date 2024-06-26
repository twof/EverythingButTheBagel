import SwiftUI
import EverythingButTheBagelCore
import UIKit
import GiphyUISDK
import CoreGraphics
import Dependencies

public struct GiphyAnimatedImageView: UIViewRepresentable, LoggingContext {
  public let loggingCategory = "GifView"
  let url: URL

  public func makeUIView(context: Context) -> GiphyYYAnimatedImageView {
    @Dependency(\.fileClient) var fileClient

    // TODO: I think we eventually want this to fail more gracefully, possibly
    // fallback to the remote datasource
    do {
      let data = try logErrors {
        try fileClient.read(url)
      }
      let view = GiphyYYAnimatedImageView(image: GiphyYYImage(data: data))
      view.contentMode = .scaleAspectFit
      view.clipsToBounds = true

      view.setContentHuggingPriority(.defaultLow, for: .vertical)
      view.setContentHuggingPriority(.defaultLow, for: .horizontal)
      view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
      view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      view.maxBufferSize = 10
      return view
    } catch {
      return GiphyYYAnimatedImageView()
    }
  }

  public func updateUIView(_ uiView: GiphyYYAnimatedImageView, context: Context) {
    print("update")
  }
}
