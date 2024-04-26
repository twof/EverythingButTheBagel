import ComposableArchitecture
import Foundation

public enum ListViewModelStatus<ViewModel: Identifiable & Codable & Equatable>: Codable, Equatable {
  case loading(data: IdentifiedArrayOf<ViewModel>, placeholders: IdentifiedArrayOf<ViewModel>)
  case loaded(data: IdentifiedArrayOf<ViewModel>)
}

extension ListViewModelStatus {
  public var data: IdentifiedArrayOf<ViewModel> {
    switch self {
    case let .loaded(data): data
    case let .loading(data, _): data
    }
  }

  public var placeholders: IdentifiedArrayOf<ViewModel> {
    switch self {
    case .loaded: []
    case let .loading(_, placeholders): placeholders
        .prefix(max(1, 7 - data.count))
        .toIdentifiedArray
    }
  }

  /// When this element comes on screen, start loading the next page
  /// Returns nil when there are no elements in `data` and the first element when there are fewer than 3
  public var loadingElement: ViewModel? {
    self.data[back: 2]
  }
}

/// Tells the underlying view model to append new items to its list or reset the list
public enum NewResponseStrategy: Equatable {
  case reset
  case append
}

/// The point of delegate actions is to alert parent reducers to some action.
public enum ListViewModelDelegate: Equatable {
  /// In this case, the parent is being alerted that the view did load.
  case task
  case nextPage
  case refresh
}

public protocol ListViewModelAction<ResponseModel> {
  associatedtype ResponseModel

  static func newResponse(_: ResponseModel, strategy: NewResponseStrategy) -> Self
  static func delegate(_: ListViewModelDelegate) -> Self
  static func scroll(position: Double) -> Self
  static func isLoading(_: Bool) -> Self
}

public protocol ListViewModelState {
  associatedtype ViewModel: Codable & Equatable & Identifiable
  var status: ListViewModelStatus<ViewModel> { get set }
  var scrollPosition: Double { get set }
}

@Reducer
public struct ListFeatureBase<
  ViewModel: Reducer,
  ResponseType: Codable & Equatable
> where
  ViewModel.State: Codable & Equatable,
  ViewModel.Action: Equatable & ListViewModelAction,
  ViewModel.Action.ResponseModel == ResponseType,
  ViewModel.State: ListViewModelState {
  public typealias DataSource = HTTPDataSourceReducer<ResponseType>

  @ObservableState
  public struct State: Codable, Equatable {
    public var viewModel: ViewModel.State
    public var dataSource: DataSource.State

    public var nextPageUrl: URL?

    public init(
      viewModel: ViewModel.State,
      dataSource: HTTPDataSourceReducer<ResponseType>.State = .init(),
      nextPageUrl: URL? = nil
    ) {
      self.viewModel = viewModel
      self.dataSource = dataSource
      self.nextPageUrl = nextPageUrl
    }
  }

  public enum Action: Equatable {
    case viewModel(ViewModel.Action)
    case dataSource(DataSource.Action)
    case refreshDataSource(DataSource.Action)
  }

  let baseUrl: String
  let errorSourceId: String
  private(set) var viewModelReducer: ViewModel
  private(set) var nextPageGenerator: ((ResponseType) -> URL?)?

  public init(baseUrl: String, errorSourceId: String, viewModelReducer: ViewModel) {
    self.baseUrl = baseUrl
    self.errorSourceId = errorSourceId
    self.viewModelReducer = viewModelReducer
  }

  public func nextPage(_ generator: @escaping (ResponseType) -> URL?) -> Self {
    var copy = self
    copy.nextPageGenerator = generator
    return copy
  }

  public var body: some Reducer<State, Action> {
    CombineReducers {
      Scope(state: \.viewModel, action: \.viewModel) {
        self.viewModelReducer
      }
      Scope(state: \.dataSource, action: \.dataSource) {
        HTTPDataSourceReducer<ResponseType>(errorSourceId: errorSourceId)
      }
      // Refresh actions are routed separately so that we know for which responses we should
      // reset the view's list content
      Scope(state: \.dataSource, action: \.refreshDataSource) {
        HTTPDataSourceReducer<ResponseType>(errorSourceId: errorSourceId)
      }
      // The base reducer is primarily responsable for routing data from the data source to
      // the view model, and user interactions from the view model to the data source
      Reduce { state, action in
        switch action {
        case let .dataSource(.delegate(.response(response))):
          state.nextPageUrl = nextPageGenerator?(response)

          return .merge(
            .send(.viewModel(.newResponse(response, strategy: .append))),
            .send(.viewModel(.isLoading(false)))
          )

        case let .refreshDataSource(.delegate(.response(response))):
          state.nextPageUrl = nextPageGenerator?(response)

          return .merge(
            .send(.viewModel(.newResponse(response, strategy: .reset))),
            .send(.viewModel(.isLoading(false)))
          )

        case .dataSource(.delegate(.error)):
          return .send(.viewModel(.isLoading(false)))

        case .viewModel(.delegate(.task)):
          // Only do the initial fetch if we're not loading from the cache
          if state.viewModel.status.data.isEmpty {
            return .send(.dataSource(.fetch(
              url: baseUrl,
              cachePolicy: .reloadIgnoringLocalCacheData
            )))
          }

          return .none

        case .viewModel(.delegate(.nextPage)):
          if let nextPage = state.nextPageUrl?.absoluteString {
            return .send(.dataSource(.fetch(
              url: nextPage,
              cachePolicy: .reloadIgnoringLocalCacheData
            )))
          }

          return .none

        case .viewModel(.delegate(.refresh)):
          return .send(.refreshDataSource(.fetch(
            url: baseUrl,
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
}
