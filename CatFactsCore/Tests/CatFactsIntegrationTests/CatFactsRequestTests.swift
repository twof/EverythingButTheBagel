import XCTest
@testable import CatFactsCore
@testable import EverythingButTheBagelCore
import Dependencies

class CatFactsRequestTests: XCTestCase {
  @MainActor
  func testFetchFacts() async throws {
    let client = DependencyValues.live[DataRequestClient<CatFactsResponseModel>.self]

    try await withDependencies { dependencies in
      dependencies.context = .live
    } operation: {
      let response = try await client.request(
        urlString: "https://catfact.ninja/facts?limit=10",
        cachePolicy: .reloadIgnoringLocalCacheData
      )
      XCTAssertEqual(response.data.count, 10)
    }
  }
}
