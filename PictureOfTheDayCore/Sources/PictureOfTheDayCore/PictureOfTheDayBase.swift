import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public typealias PictureOfTheDayBase = ListFeatureBase<PictureOfTheDayViewModelReducer, [POTDResponseModel]>

public extension PictureOfTheDayBase {
  private static var urlString: String {
    @Dependency(\.apiKeys) var apiKeys
    return "https://api.nasa.gov/planetary/apod&count=20&api_key=\(apiKeys.potd())"
  }

  private static func urlGenerator() -> URL? {
    guard let url = URL(string: urlString) else {
      @Dependency(\.loggingClient) var loggingClient
      loggingClient.log(
        level: .error(error: NetworkRequestError.malformedURLError(urlString: urlString).toEquatableError()),
        category: "PictureOfTheDayDataSource"
      )

      return nil
    }

    return url
  }

  static var potd: PictureOfTheDayBase {
    PictureOfTheDayBase().nextPage { _ in Self.urlGenerator() }
  }
}

public extension PictureOfTheDayBase.State {
  init(nextPageUrl: URL? = nil) {
    self.init(viewModel: .init(), nextPageUrl: nextPageUrl)
  }
}

public extension PictureOfTheDayBase {
  init() {
    self.init(
      baseUrl: Self.urlString,
      errorSourceId: "PictureOfTheDayDataSource",
      viewModelReducer: PictureOfTheDayViewModelReducer()
    )
  }
}
