import XCTest
import SwiftUI

class AccessibilityAuditTests: XCTestCase {
  func testText() {
    let view = Text("Hello world")
    view.accessibilityAudit()
  }

  func testTextGroup() {
    let view = VStack {
      Text("Hello world")
    }
    view.accessibilityAudit()
  }
}
