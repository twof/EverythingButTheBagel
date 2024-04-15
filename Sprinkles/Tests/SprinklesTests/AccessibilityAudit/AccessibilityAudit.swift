import SwiftUI
import ViewInspector
import XCTest

extension View {
  func accessibilityAudit() {
    let allSubviews = try! self.inspect().findAll { _ in true }
    for subview in allSubviews {

      // If it's text, don't worry about accessiblity
      if (try? subview.text()) != nil || (try? subview.textField()) != nil {
        continue
      }

      // If it's a container, don't worry about accessiblity
      if
        (try? subview.zStack()) != nil ||
          (try? subview.hStack()) != nil ||
          (try? subview.vStack()) != nil
      {
      continue
      }

      do {
        _ = try subview.accessibilityLabel()
      } catch {
        XCTFail("Value does not exist for view \(subview)")
      }
    }
  }
}
