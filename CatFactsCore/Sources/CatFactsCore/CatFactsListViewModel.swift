import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public typealias CatFactsListViewModelReducer = ListFeatureViewModelReducer<CatFactViewModel, CatFactsResponseModel>

public extension CatFactsListViewModelReducer {
  static var catFacts: CatFactsListViewModelReducer {
    ListFeatureViewModelReducer { response in
      response.data.map(CatFactViewModel.init(model:))
    }
  }
}

public struct CatFactViewModel: Codable, Equatable, Identifiable {
  public var id: String { fact }
  public let fact: String

  public init(model: CatFactModel) {
    self.fact = model.fact
  }

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
