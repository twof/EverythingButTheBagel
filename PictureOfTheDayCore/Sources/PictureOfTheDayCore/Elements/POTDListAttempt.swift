import ComposableArchitecture
import EverythingButTheBagelCore
import Foundation

@Reducer
public struct POTDListAttemptBase {
  public typealias DataSource = HTTPDataSourceReducer<[POTDResponseModel]>
  @ObservableState
  public struct State: Codable, Equatable {
    public var elements: ListViewModelStatus<PictureOfTheDayItemBase.State>
    public var viewModel: POTDListAttemptVM.State
    public var dataSource: DataSource.State

    var dataModels: IdentifiedArrayOf<POTDResponseModel> = []

    public init(
      elements: ListViewModelStatus<PictureOfTheDayItemBase.State> = .loaded(data: []),
      viewModel: POTDListAttemptVM.State = .init(),
      dataSource: DataSource.State = .init()
    ) {
      self.elements = elements
      self.viewModel = viewModel
      self.dataSource = dataSource
    }

    mutating func setLoading(_ isLoading: Bool) {
      let data = elements.data

      elements = isLoading
        ? .loading(data: data, placeholders: .placeholders)
        : .loaded(data: data)
    }
  }

  public enum Action: Equatable {
    case element(IdentifiedActionOf<PictureOfTheDayItemBase>)
    case viewModel(POTDListAttemptVM.Action)
    case dataSource(DataSource.Action)
    case refreshDataSource(DataSource.Action)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.viewModel, action: \.viewModel) {
      POTDListAttemptVM()
    }

    Scope(state: \.dataSource, action: \.dataSource) {
      DataSource(errorSourceId: "POTDDataSource")
    }

    Scope(state: \.dataSource, action: \.refreshDataSource) {
      DataSource(errorSourceId: "POTDDataSource")
    }

    Reduce { state, action in
      switch action {
      case .viewModel(.delegate(.task)):
        // Only do the initial fetch if we're not loading from the cache
        if state.elements.data.isEmpty {
          state.setLoading(true)
          return .send(.dataSource(.fetch(url: Self.urlString, cachePolicy: .useProtocolCachePolicy)))
        }
        return .none

      case let .dataSource(.delegate(.response(response))):
        state.elements = state.elements.appending(contentsOf: response.map(\.listItemBase))
        state.dataModels.append(contentsOf: response)
        state.setLoading(false)
        return .none

      case .viewModel(.delegate(.refresh)):
        state.setLoading(true)
        return .send(.refreshDataSource(.fetch(url: Self.urlString, cachePolicy: .useProtocolCachePolicy)))

      case let .refreshDataSource(.delegate(.response(response))):
        state.elements = .loaded(data: response.map(\.listItemBase).toIdentifiedArray)
        state.dataModels = response.toIdentifiedArray
        state.setLoading(false)
        return .none

      case let .element(.element(id, .viewModel(.delegate(.didAppear)))):
        // Figure out how close we are to the bottom and prefetch if it's time
        guard let index = state.elements.data.index(id: id) else {
          return .none
        }

        // Start loading three from the bottom
        if index == state.elements.data.endIndex - 3 {
          return .send(.dataSource(.fetch(url: Self.urlString, cachePolicy: .useProtocolCachePolicy)))
        }

        return .none

      case let .element(.element(id, .viewModel(.delegate(.didTap)))):
        guard let element = state.dataModels[id: id] else {
          return .none
        }
        return .send(
          .viewModel(
            .navigateToPath(
              .detail(PictureOfTheDayDetailBase.State(
                asyncImage: .init(imageUrl: element.hdurl ?? element.url),
                viewModel: .init(title: element.title, description: element.explanation)
              ))
            )
          )
        )

      case .element, .dataSource, .viewModel, .refreshDataSource:
        return .none
      }
    }.forEach(\.elements.data, action: \.element) {
      PictureOfTheDayItemBase()
    }
  }

  static var urlString: String {
    @Dependency(\.apiKeys) var apiKeys
    return "https://api.nasa.gov/planetary/apod?thumbs=true&count=20&api_key=\(apiKeys.potd())"
  }
}

extension POTDResponseModel {
  var listItemBase: PictureOfTheDayItemBase.State {
    PictureOfTheDayItemBase.State(title: title, asyncImage: AsyncImageBase.State(imageUrl: thumbnailUrl ?? url))
  }
}

@Reducer
public struct POTDListAttemptVM {
  @ObservableState
  public struct State: Codable, Equatable {
    public static let emptyListString = LocalizedTextState(
      text: String(
        localized: "No pictures here! Pull to refresh to check again.",
        bundle: .module,
        comment: "Message to let the user know that there are no list items, but not due to an error."
      ),
      stringCatalogLocation: .pictureOfTheDayStringCatalog
    )

    public let emptyListMessage: LocalizedTextState
    public var scrollPosition: Double

    public var path: StackState<POTDPath.State>

    public init(
      scrollPosition: Double = 0.0,
      emptyListMessage: LocalizedTextState = Self.emptyListString,
      path: StackState<POTDPath.State> = .init()
    ) {
      self.scrollPosition = scrollPosition
      self.emptyListMessage = emptyListMessage
      self.path = path
    }

    enum CodingKeys: CodingKey {
      // swiftlint:disable:next identifier_name
      case _scrollPosition
      case emptyListMessage
      // swiftlint:disable:next identifier_name
      case _path
    }
  }

  public enum Action: Equatable {
    @CasePathable
    public enum Delegate: Equatable {
      case task
      case refresh
    }

    case scroll(position: Double)
    case path(StackActionOf<POTDPath>)
    case navigateToPath(POTDPath.State)
    case delegate(Delegate)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .scroll(position):
        state.scrollPosition = position
        return .none

      case let .navigateToPath(path):
        state.path.append(path)
        return .none

      case .delegate, .path:
        return .none
      }
    }.forEach(\.path, action: \.path) {
      POTDPath.State.StateReducer.body
    }
  }
}
