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

    public init(
      elements: ListViewModelStatus<PictureOfTheDayItemBase.State>,
      viewModel: POTDListAttemptVM.State = .init(),
      dataSource: DataSource.State = .init()) {
      self.elements = elements
      self.viewModel = viewModel
      self.dataSource = dataSource
    }
  }

  public enum Action: Equatable {
    case element(IdentifiedActionOf<PictureOfTheDayItemBase>)
    case viewModel(POTDListAttemptVM.Action)
    case dataSource(DataSource.Action)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.viewModel, action: \.viewModel) {
      POTDListAttemptVM()
    }

    Scope(state: \.dataSource, action: \.dataSource) {
      DataSource(errorSourceId: "POTDDataSource")
    }

    Reduce { state, action in
      switch action {
      case .viewModel(.delegate(.task)):
        return .send(.dataSource(.fetch(url: Self.urlString, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy)))
      case let .dataSource(.delegate(.response(response))):
        state.elements = state.elements.appending(contentsOf: response.map { PictureOfTheDayItemBase.State(title: $0.title, asyncImage: AsyncImageBase.State(imageUrl: $0.url)) })
        return .none
      case .element, .dataSource, .viewModel:
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

extension ListViewModelStatus where ViewModel == PictureOfTheDayItemBase.State {

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
