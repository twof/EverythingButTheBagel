import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public typealias PictureOfTheDayBase = ListFeatureBase<PictureOfTheDayViewModel, [POTDResponseModel]>

public extension PictureOfTheDayBase {
  private static let errorSourceId = "PictureOfTheDayDataSource"

  init() {
    self.init(
      baseUrl: Self.urlString,
      errorSourceId: Self.errorSourceId,
      viewModelReducer: PictureOfTheDayViewModelReducer.potd
    )
  }

  static var urlString: String {
    @Dependency(\.apiKeys) var apiKeys
    return "https://api.nasa.gov/planetary/apod?thumbs=true&count=20&api_key=\(apiKeys.potd())"
  }

  private static func urlGenerator() -> URL? {
    guard let url = URL(string: urlString) else {
      @Dependency(\.loggingClient) var loggingClient
      loggingClient.log(
        level: .error(error: NetworkRequestError.malformedURLError(urlString: urlString).toEquatableError()),
        category: errorSourceId
      )

      return nil
    }

    return url
  }

  /// Default instance of the reducer
  /// On scolling to the next page, requests another set of random pictures
  static var potd: PictureOfTheDayBase {
    PictureOfTheDayBase().nextPage { _ in urlGenerator() }
  }
}

public extension PictureOfTheDayBase.State {
  init(nextPageUrl: URL? = nil) {
    self.init(viewModel: .init(), nextPageUrl: nextPageUrl)
  }
}
