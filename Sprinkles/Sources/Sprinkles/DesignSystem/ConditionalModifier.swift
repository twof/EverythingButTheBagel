import SwiftUI

// Source: https://designcode.io/swiftui-handbook-conditional-modifier
extension View {
  @ViewBuilder public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
