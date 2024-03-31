import CoreGraphics
import SwiftUI

public struct DesignSystem { }

extension DesignSystem {
  public struct Colors {
    private init() { }

    static let textPrimary = Color("TextPrimary")
  }
}

extension Color {
  public static let textPrimary = DesignSystem.Colors.textPrimary
}
