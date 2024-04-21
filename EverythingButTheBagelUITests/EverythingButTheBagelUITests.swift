import XCTest

final class EverythingButTheBagelUITests: XCTestCase {
  func testExample() throws {
    let app = XCUIApplication()
    app.launch()

    try app.performAccessibilityAudit { issue in
      print(issue)
      return true
    }
  }
}
