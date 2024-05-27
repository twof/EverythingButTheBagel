import ComposableArchitecture
import EverythingButTheBagelCore
import Foundation

@Reducer
public struct ElementsBase {
  public struct State: Codable, Equatable {
    public var elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>

    public init(elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>) {
      self.elements = elements
    }
  }

  @CasePathable
  public enum Action: Equatable {
    case element(IdentifiedActionOf<PictureOfTheDayItemBase>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      return .none
    }.forEach(\.elements, action: \.element) {
      PictureOfTheDayItemBase()
    }
  }
}

@Reducer
public struct POTDListAttemptBase {

  public typealias DataSource = HTTPDataSourceReducer<[POTDResponseModel]>
  @ObservableState
  public struct State: Codable, Equatable {
    public var elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>
    public var viewModel: POTDListAttemptVM.State
    public var dataSource: DataSource.State

    public init(elements: IdentifiedArrayOf<PictureOfTheDayItemBase.State>, viewModel: POTDListAttemptVM.State = .init(), dataSource: DataSource.State = .init()) {
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
        state.elements.append(contentsOf: response.map { PictureOfTheDayItemBase.State(title: $0.title, asyncImage: AsyncImageBase.State(imageUrl: $0.url)) })
        return .none
      case .element, .dataSource, .viewModel:
        return .none
      }
    }.forEach(\.elements, action: \.element) {
      PictureOfTheDayItemBase()
    }
  }

  static var urlString: String {
    @Dependency(\.apiKeys) var apiKeys
    return "https://api.nasa.gov/planetary/apod?thumbs=true&count=20&api_key=\(apiKeys.potd())"
  }

//  private static func urlGenerator() -> URL? {
//    guard let url = URL(string: urlString) else {
//      @Dependency(\.loggingClient) var loggingClient
//      loggingClient.log(
//        level: .error(error: NetworkRequestError.malformedURLError(urlString: urlString).toEquatableError()),
//        category: errorSourceId
//      )
//
//      return nil
//    }
//
//    return url
//  }
}

@Reducer
public struct POTDListAttemptVM {
  @ObservableState
  public struct State: Codable, Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    @CasePathable
    public enum Delegate: Equatable {
      case task
    }

    case delegate(Delegate)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      return .none
    }
  }
}
