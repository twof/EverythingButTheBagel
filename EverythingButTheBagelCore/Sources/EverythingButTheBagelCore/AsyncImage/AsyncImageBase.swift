import ComposableArchitecture
import Foundation

@Reducer
public struct AsyncImageBase {
  public typealias DataSource = HTTPDataSourceReducer<Data>
  @ObservableState
  public struct State: Codable, Equatable {
    let imageUrl: URL

    public var dataSource: DataSource.State
    public var viewModel: AsyncImageViewModel.State

    public init(
      imageUrl: URL,
      dataSource: DataSource.State = .init(),
      viewModel: AsyncImageViewModel.State = .init()
    ) {
      self.imageUrl = imageUrl
      self.dataSource = dataSource
      self.viewModel = viewModel
    }
  }

  public enum Action: Equatable {
    case dataSource(DataSource.Action)
    case viewModel(AsyncImageViewModel.Action)
  }

  public init() { }

  public var body: some ReducerOf<AsyncImageBase> {
    CombineReducers {
      Scope(state: \State.dataSource, action: \.dataSource) {
        DataSource(errorSourceId: "AsyncImageLoader", maxRetries: 0)
      }

      Scope(state: \.viewModel, action: \.viewModel) {
        AsyncImageViewModel()
      }

      Reduce { state, action in
        switch action {
        case .viewModel(.delegate(.task)):
          return .send(.dataSource(.fetch(
            url: state.imageUrl.absoluteString,
            cachePolicy: .returnCacheDataElseLoad
          )))
        case let .dataSource(.delegate(.response(data))):
          return .send(.viewModel(.newResponse(data)))

        case .dataSource, .viewModel:
          return .none
        }
      }
    }
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
