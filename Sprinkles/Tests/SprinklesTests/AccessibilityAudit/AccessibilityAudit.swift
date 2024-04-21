import SwiftUI
import ViewInspector
import XCTest

/*
 Unhandled rules:
 - If text falls outside of the screen and it can't be scrolled to, then that qualifies as clipping.
  - Test case: Very long string in a text view not in a scroll view
 - Text clipping at larger dynamic type generally.
 - Text truncation at larger sizes qualifies as clipping
 */

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
