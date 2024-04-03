import ComposableArchitecture
import Foundation

public struct CatFactsResponseModel: Codable, Equatable {
  let currentPage: Int
  let data: [CatFactModel]
  let nextPageUrl: URL?

  // API uses snake case keys
  enum CodingKeys: String, CodingKey {
    case currentPage = "current_page"
    case data
    case nextPageUrl = "next_page_url"
  }
}

public struct CatFactModel: Codable, Equatable {
  let fact: String
}
