import XCTest
@testable import PictureOfTheDayCore
@testable import EverythingButTheBagelCore
import Dependencies

// class PictureOfTheDayRequestTests: XCTestCase {
//  @MainActor
//  func testFetch() async throws {
//    let client = DependencyValues.live[DataRequestClient<[POTDResponseModel]>.self]
//
//    try await withDependencies { dependencies in
//      dependencies.context = .live
//    } operation: {
//      let response = try await client.request(
//        urlString: PictureOfTheDayBase.urlString,
//        cachePolicy: .reloadIgnoringLocalCacheData
//      )
//      XCTAssertEqual(response.count, 20)
//    }
//  }
// }
