import Foundation
import ComposableArchitecture
import UIKit

public enum ImageType: Codable, Equatable, Sendable {
  /// Local URL
  case staticImage(URL)
  /// Local URL usually, remote URLs partially supported
  case animatedGif(URL)

  /// Expected to be a local URL
  public init(url: URL) {
    if url.lastPathComponent.contains(".gif") {
      self = .animatedGif(url)
    } else {
      self = .staticImage(url)
    }
  }
}

@Reducer
public struct AsyncImageViewModel {
  @ObservableState
  public struct State: Equatable, Codable, Sendable {
    public var imageType: ImageType?
    public var isLoading: Bool = false
    public let imageName: String
    public var imageData: UIImage?

    public init(imageName: String, imageType: ImageType? = nil, isLoading: Bool, imageData: UIImage? = nil) {
      self.imageName = imageName
      self.imageType = imageType
      self.isLoading = isLoading
      self.imageData = imageData
    }

    enum CodingKeys: CodingKey {
      // swiftlint:disable:next identifier_name
      case _imageType
      // swiftlint:disable:next identifier_name
      case _isLoading
      case imageName
    }
  }

  public enum Action: Equatable {
    public enum Delegate: Equatable {
      /// Called when cell appears
      case task
      case disappear
    }

    case delegate(Delegate)
    case newResponse(ImageType)
    case dataLoaded(Data)
    case imageRendered(UIImage)
    case isLoading(Bool)
  }

  public init() {}

  public var body: some ReducerOf<AsyncImageViewModel> {
    Reduce { state, action in
      switch action {
      case let .isLoading(isLoading):
        state.isLoading = isLoading
        return .none

      case let .newResponse(imageType):
        state.imageType = imageType

        return .none

      case let .dataLoaded(data):
        return .run(priority: .background) { send in
          // TODO: Should throw if rendering fails
          guard let uiImage = UIImage(data: data) else { return }
          await send(.imageRendered(uiImage))
        }

      case let .imageRendered(image):
        state.imageData = image
        return .none

      case .delegate(.disappear):
        state.imageData = nil
        return .none

      case .delegate:
        return .none
      }
    }
  }
}
