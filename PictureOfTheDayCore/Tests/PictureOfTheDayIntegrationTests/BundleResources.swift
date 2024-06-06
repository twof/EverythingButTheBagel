import XCTest
@testable import PictureOfTheDayCore
@testable import EverythingButTheBagelCore
import Dependencies

final class BundleResources: XCTestCase {
  func testSetup() throws {
    let url = URL.pictureOfTheDayStringCatalog
    print(url)
  }
}
