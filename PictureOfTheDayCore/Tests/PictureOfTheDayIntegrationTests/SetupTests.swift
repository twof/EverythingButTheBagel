import XCTest
@testable import PictureOfTheDayCore
import Dependencies
import SwiftDotenv

final class SetupTests: XCTestCase {
  func testSetup() throws {
    let client = DependencyValues.live.pictureOfTheDaySetup
    try client()
    print(Dotenv.values)
  }
}
