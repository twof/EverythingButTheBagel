import XCTest
@testable import Sprinkles
import SwiftUI
import ViewInspector

struct ExampleView: View {
  var body: some View {
    VStack {
      Text("hello")
      Text("hello")
      Text("hello")
      Text("hello")
    }
  }
}

final class SprinklesTests: XCTestCase {
  func testExample() throws {
    let view = ExampleView()
    view.accessibilityAudit()
  }
}
