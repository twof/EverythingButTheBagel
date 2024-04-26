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
      viewModel: .init(
        emptyListMessage: LocalizedTextState(
          text: String(
            localized: "No facts here! Pull to refresh to check again.",
            bundle: .module,
            comment: "Message to let the user know that there are no list items, but not due to an error."
          ),
          stringCatalogLocation: .catFactsStringCatalog
        )
      ),
      nextPageUrl: nextPageUrl)
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
