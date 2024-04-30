import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public typealias CatFactsListViewModelReducer = ListFeatureViewModelReducer<CatFactViewModel, EmptyPathReducer>

public extension CatFactsListViewModelReducer {
  static var catFacts: CatFactsListViewModelReducer {
    ListFeatureViewModelReducer()
  }
}

public extension CatFactsListViewModelReducer.State {
  init() {
    self.init(
      emptyListMessage: LocalizedTextState(
        text: String(
          localized: "No facts here! Pull to refresh to check again.",
          bundle: .module,
          comment: "Message to let the user know that there are no list items, but not due to an error."
        ),
        stringCatalogLocation: .catFactsStringCatalog
      )
    )
  }
}

public struct CatFactViewModel: Codable, Equatable, Identifiable {
  public var id: String { fact }
  public let fact: String

  public init(fact: String) {
    self.fact = fact
  }
}

extension CatFactViewModel: ViewModelPlaceholders {
  public static let placeholders = (0..<20).map {
    CatFactViewModel(
      fact: "Example of a long fact Example of a long fact Example of a long fact"
      + "Example of a long fact Example of a long fact Example of a long fact Example of a long"
      + "fact Example of a long fact \($0)"
    )
  }
}

extension CatFactViewModel: ViewModelConvertable {
  public init(model: CatFactModel) {
    self.fact = model.fact
  }
}
