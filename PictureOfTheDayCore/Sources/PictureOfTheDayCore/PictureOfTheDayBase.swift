import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayBase {
  public static let baseURL = "https://api.nasa.gov/planetary/apod"
  public static let errorSourceId = "PictureOfTheDayDataSource"
  public typealias DataSource = HTTPDataSourceReducer<[POTDResponseModel]>

  @ObservableState
  public struct State: Codable, Equatable {
    public var viewModel: PictureOfTheDayViewModelReducer.State
    public var dataSource: DataSource.State

    public init(
      viewModel: PictureOfTheDayViewModelReducer.State = .init(),
      dataSource: DataSource.State = .init()
    ) {
      self.viewModel = viewModel
      self.dataSource = dataSource
    }
  }

  public enum Action: Equatable {
    case viewModel(PictureOfTheDayViewModelReducer.Action)
    case dataSource(DataSource.Action)
    case refreshDataSource(DataSource.Action)
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    CombineReducers {
      Scope(state: \.viewModel, action: \.viewModel) {
        PictureOfTheDayViewModelReducer()
      }
      Scope(state: \.dataSource, action: \.dataSource) {
        DataSource(errorSourceId: PictureOfTheDayBase.errorSourceId)
      }
      // Refresh actions are routed separately so that we know for which responses we should
      // reset the view's list content
      Scope(state: \.dataSource, action: \.refreshDataSource) {
        DataSource(errorSourceId: PictureOfTheDayBase.errorSourceId)
      }
      // The base reducer is primarily responsable for routing data from the data source to
      // the view model, and user interactions from the view model to the data source
      Reduce { state, action in
        switch action {
        case let .dataSource(.delegate(.response(response))):

          return .merge(
            .send(.viewModel(.newElements(response, strategy: .append))),
            .send(.viewModel(.isLoading(false)))
          )

        case let .refreshDataSource(.delegate(.response(response))):
          return .merge(
            .send(.viewModel(.newElements(response, strategy: .reset))),
            .send(.viewModel(.isLoading(false)))
          )

        case .dataSource(.delegate(.error)):
          return .send(.viewModel(.isLoading(false)))

        case .viewModel(.delegate(.task)):
          // Only do the initial fetch if we're not loading from the cache
          if state.viewModel.status.data.isEmpty {
            return .send(.dataSource(.fetch(
              url: urlGenerator(baseUrl: Self.baseURL, count: 40),
              cachePolicy: .reloadIgnoringLocalCacheData
            )))
          }

          return .none

        case .viewModel(.delegate(.nextPage)):
          return .send(.dataSource(.fetch(
            url: urlGenerator(baseUrl: Self.baseURL, count: 40),
            cachePolicy: .reloadIgnoringLocalCacheData
          )))

        case .viewModel(.delegate(.refresh)):
          return .send(.refreshDataSource(.fetch(
            url: urlGenerator(baseUrl: PictureOfTheDayBase.baseURL, count: 40),
            cachePolicy: .reloadIgnoringLocalCacheData
          )))

        case .dataSource(.fetch):
          return .send(.viewModel(.isLoading(true)))

        case .dataSource, .viewModel, .refreshDataSource:
          return .none
        }
      }
    }
  }

  private func urlGenerator(baseUrl: String, count: Int) -> String {
    @Dependency(\.apiKeys) var apiKeys
    return "\(baseUrl)&count=\(count)&api_key=\(apiKeys.potd())"
  }
}
