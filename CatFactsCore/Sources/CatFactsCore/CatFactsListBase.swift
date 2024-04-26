import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public typealias CatFactsListBase = ListFeatureBase<CatFactsListViewModelReducer, CatFactsResponseModel>

public extension CatFactsListBase {
  static var catFacts: CatFactsListBase {
    ListFeatureBase().nextPage { response in
      response.nextPageUrl?.appending(queryItems: [.init(name: "limit", value: "40")])
    }
  }
}

public extension CatFactsListBase.State {
  init(nextPageUrl: URL? = nil) {
    self.init(
      viewModel: .init(),
      nextPageUrl: nextPageUrl
    )
  }
}

public extension CatFactsListBase {
  init() {
    self.init(
      baseUrl: "https://catfact.ninja/facts?page=1&limit=40",
      errorSourceId: "CatFactsDataSource",
      viewModelReducer: .catFacts
    )
  }
}
