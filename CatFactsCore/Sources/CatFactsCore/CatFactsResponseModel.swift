import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public struct CatFactsResponseModel: Codable, Equatable {
  public let currentPage: Int
  public let data: [CatFactModel]
  public let nextPageUrl: URL?

  public init(currentPage: Int = 0, data: [CatFactModel], nextPageUrl: URL? = nil) {
    self.currentPage = currentPage
    self.data = data
    self.nextPageUrl = nextPageUrl
  }

  // API uses snake case keys
  enum CodingKeys: String, CodingKey {
    case currentPage = "current_page"
    case data
    case nextPageUrl = "next_page_url"
  }
}

extension CatFactsResponseModel: ListResponse {
  public var modelList: [CatFactModel] {
    self.data
  }
}

extension CatFactsResponseModel {
  public static let mock = CatFactsResponseModel(
    currentPage: 0,
    data: [.init(fact: "first fact"), .init(fact: "second fact")],
    nextPageUrl: URL(string: "https://catfact.ninja/facts?page=2")
  )
}

public struct CatFactModel: Codable, Equatable {
  let fact: String
}

extension CatFactModel: Identifiable {
  public var id: String { fact }
}
