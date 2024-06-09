import ComposableArchitecture
import Foundation

@Reducer
public struct AsyncImageCoordinator: LoggingContext {
  public let loggingCategory: String = "AsyncImageCoordinator"

  public typealias HTTPDataSource = HTTPDataSourceReducer<Data>
  @ObservableState
  public struct State: Codable, Equatable {
    public let imageUrl: URL
    public let imageName: String

    public var dataSource: HTTPDataSource.State
    public var viewModel: AsyncImageViewModel.State

    public init(
      imageUrl: URL,
      imageName: String,
      dataSource: HTTPDataSource.State = .init(),
      viewModel: AsyncImageViewModel.State? = nil
    ) {
      self.imageUrl = imageUrl
      self.imageName = imageName
      self.dataSource = dataSource
      self.viewModel = viewModel ?? .init(imageName: imageName, isLoading: false)
    }
  }

  public enum Action: Equatable {
    case dataSource(HTTPDataSource.Action)
    case viewModel(AsyncImageViewModel.Action)

    case imageCached(URL)
  }

  @Dependency(\.fileClient) var fileClient

  public init() {}

  public var body: some ReducerOf<AsyncImageCoordinator> {
    CombineReducers {
      Scope(state: \State.dataSource, action: \.dataSource) {
        // We're creating an ephemeral data source. This turns off `URLSession`'s
        // built in `URLCache`. We want to do that because we're going to cache images on
        // disk, and we don't want images taking up too much memory.
        HTTPDataSource(errorSourceId: "AsyncImageDataSource", maxRetries: 3, sessionConfig: .ephemeral)
      }

      Scope(state: \.viewModel, action: \.viewModel) {
        AsyncImageViewModel()
      }

      Reduce { state, action in
        switch action {
        case .viewModel(.delegate(.task)):
          // Image is already loaded, don't try to reload
          guard state.viewModel.imageType == nil else {
            return .none
          }

          let url = Self.localImageURL(filename: state.imageName)

          if fileClient.exists(url) {
            return .send(.imageCached(url))
          }

          // File not found on disk, fetch from server
          return .send(.dataSource(.fetch(
            url: state.imageUrl.absoluteString,
            cachePolicy: .returnCacheDataElseLoad
          )))

        case let .dataSource(.delegate(.response(data))):
          // If we fail to cache the image, fall back to loading from
          // the remote URL
          do {
            let url = Self.localImageURL(filename: state.imageName)
            try logErrors {
              try fileClient.write(url, data)
            }

            return .merge(
              .send(.imageCached(url)),
              .send(.viewModel(.isLoading(false)))
            )
          } catch {
            // TODO: The GIFView isn't going to handle
            // this very well right now
            return .merge(
              .send(.imageCached(state.imageUrl)),
              .send(.viewModel(.isLoading(false)))
            )
          }

        case .dataSource(.delegate(.error)):
          return .send(.viewModel(.isLoading(false)))

        case .dataSource(.fetch):
          return .send(.viewModel(.isLoading(true)))

        case let .imageCached(url):
          return .send(.viewModel(.newResponse(ImageType(url: url))))

        case .dataSource, .viewModel:
          return .none
        }
      }
    }
  }

  static func localImageURL(filename: String) -> URL {
    let fileManager = FileManager.default
    // Using the `cachesDirectory` which hides the cache file from the user and allows the
    // OS to clear the cache if it needs to free up space
    return fileManager
      .urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(filename)
  }
}

extension Shared: Codable where Value: Codable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.wrappedValue)
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let val = try container.decode(Value.self)
    self.init(val)
  }
}
