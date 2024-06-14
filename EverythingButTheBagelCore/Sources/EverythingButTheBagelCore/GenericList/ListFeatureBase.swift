import ComposableArchitecture
import Foundation

public protocol ListResponse {
  associatedtype Model
  var modelList: [Model] { get }
}

extension Array: ListResponse {
  public var modelList: [Element] {
    return self
  }
}

public protocol ViewModelConvertable {
  associatedtype Model
  init(model: Model)
}

// swiftlint:disable opening_brace
@Reducer
public struct ListFeatureBase<
  ViewModel: Codable & Equatable & Identifiable & ViewModelPlaceholders & ViewModelConvertable,
  ResponseType: Codable & Equatable & ListResponse,
  PathReducer: CaseReducer
> where
  PathReducer.Action: Equatable,
  PathReducer.State: Equatable & Codable & CaseReducerState & ObservableState,
  PathReducer.State.StateReducer.Action == PathReducer.Action,
  ViewModel.Model == ResponseType.Model,
  ResponseType.Model: Codable & Equatable & Identifiable,
  ResponseType.Model.ID == ViewModel.ID
{
  // swiftlint:enable opening_brace
  public typealias DataSource = HTTPDataSourceReducer<ResponseType>
  public typealias ViewModelReducer = ListFeatureViewModelReducer<ViewModel, PathReducer>

  @ObservableState
  public struct State: Codable, Equatable {
    public var viewModel: ViewModelReducer.State
    public var dataSource: DataSource.State

    public var nextPageUrl: URL?

    var lastResponse: IdentifiedArrayOf<ResponseType.Model>?

    public init(
      viewModel: ViewModelReducer.State,
      dataSource: HTTPDataSourceReducer<ResponseType>.State = .init(),
      nextPageUrl: URL? = nil
    ) {
      self.viewModel = viewModel
      self.dataSource = dataSource
      self.nextPageUrl = nextPageUrl
    }
  }

  public enum Action: Equatable {
    case viewModel(ViewModelReducer.Action)
    case dataSource(DataSource.Action)
    case refreshDataSource(DataSource.Action)
  }

  let baseUrl: String
  let errorSourceId: String
  private(set) var viewModelReducer: ViewModelReducer
  private(set) var nextPageGenerator: ((ResponseType) -> URL?)?
  private(set) var navigateTo: ((ResponseType.Model) -> PathReducer.State?)?

  public init(baseUrl: String, errorSourceId: String, viewModelReducer: ViewModelReducer) {
    self.baseUrl = baseUrl
    self.errorSourceId = errorSourceId
    self.viewModelReducer = viewModelReducer
  }

  public func nextPage(_ generator: @escaping (ResponseType) -> URL?) -> Self {
    var copy = self
    copy.nextPageGenerator = generator
    return copy
  }

  public func onTap(_ navigateTo: @escaping (ResponseType.Model) -> PathReducer.State?) -> Self {
    var copy = self
    copy.navigateTo = navigateTo
    return copy
  }

  private func handleNewResponse(state: inout State, response: ResponseType) -> [ViewModel] {
    state.nextPageUrl = nextPageGenerator?(response)
    state.lastResponse = response.modelList.toIdentifiedArray

    return response.modelList.map { model in
      ViewModel(model: model)
    }
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
        case let .viewModel(.delegate(.rowTapped(rowId))):
          guard
            let item = state.lastResponse?[id: rowId],
            let destination = navigateTo?(item)
          else {
            return .none
          }

          return .send(.viewModel(.navigateToPath(destination)))

        case let .dataSource(.delegate(.response(response))):
          let vms = handleNewResponse(state: &state, response: response)

          return .merge(
            .send(.viewModel(.newResponse(vms, strategy: .append))),
            .send(.viewModel(.isLoading(false)))
          )

        case let .refreshDataSource(.delegate(.response(response))):
          let vms = handleNewResponse(state: &state, response: response)

          return .merge(
            .send(.viewModel(.newResponse(vms, strategy: .reset))),
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
