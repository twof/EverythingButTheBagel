//
//  EverythingButTheBagelUITests.swift
//  EverythingButTheBagelUITests
//
//  Created by fnord on 4/10/24.
//

import XCTest

final class EverythingButTheBagelUITests: XCTestCase {
  func testExample() throws {
    let app = XCUIApplication()
    app.launch()

    try app.performAccessibilityAudit()
  }
}
