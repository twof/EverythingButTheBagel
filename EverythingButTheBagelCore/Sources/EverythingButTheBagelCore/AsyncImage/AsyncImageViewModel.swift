// import Foundation
// import ComposableArchitecture
//
// @Reducer
// public struct AsyncImageViewModel {
//  @ObservableState
//  public struct State: Equatable, Codable {
//    public var imageData: Data?
//
//    public init(imageData: Data? = nil) {
//      self.imageData = imageData
//    }
//  }
//
//  public enum Action: Equatable {
//    public enum Delegate: Equatable {
//      case task
//    }
//
//    case delegate(Delegate)
//    case newResponse(Data)
//  }
//
//  public init() {}
//
//  public var body: some ReducerOf<AsyncImageViewModel> {
//    Reduce { state, action in
//      switch action {
//      case let .newResponse(data):
//        state.imageData = data
//        return .none
//      case .delegate:
//        return .none
//      }
//    }
//  }
// }

import Foundation
import ComposableArchitecture

public enum ImageType: Codable, Equatable {
  case staticImage(URL)
  // Local URL usually, remote URLs partially supported
  case animatedGif(URL)

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
  public struct State: Equatable, Codable {
    public var imageType: ImageType?
    public var isLoading: Bool = false
    public let imageName: String
    public var imageData: Data?

    public init(imageName: String, imageType: ImageType? = nil, isLoading: Bool, imageData: Data? = nil) {
      self.imageName = imageName
      self.imageType = imageType
      self.isLoading = isLoading
      self.imageData = imageData
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
        state.imageData = data
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
