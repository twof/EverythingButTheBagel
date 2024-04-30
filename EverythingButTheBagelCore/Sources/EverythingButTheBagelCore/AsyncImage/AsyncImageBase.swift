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
      viewModel: AsyncImageViewModel.State = .init(isLoading: false)
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

  public init() {}

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
            cachePolicy: .reloadIgnoringLocalCacheData
          )))
        case let .dataSource(.delegate(.response(data))):
          return .merge(
            .send(.viewModel(.newResponse(data))),
            .send(.viewModel(.isLoading(false)))
          )

        case .dataSource(.delegate(.error)):
          return .send(.viewModel(.isLoading(false)))

        case .dataSource(.fetch):
          return .send(.viewModel(.isLoading(true)))

        case .dataSource, .viewModel:
          return .none
        }
      }
    }
  }
}