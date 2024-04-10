import SwiftUI
import Dependencies
import EverythingButTheBagelCore

/// Wrapper around `SwiftUI.Text` that forwards `@Environment(\.locale)` to `LocalizedTextState`
///
/// The point here is to move control of localization from the views to our business logic package
struct LocalizedText: View {
  let state: LocalizedTextState
  @Environment(\.locale) var locale

  init(_ string: String) {
    self.state = LocalizedTextState(text: string)
  }

  init(_ state: LocalizedTextState) {
    self.state = state
  }

  var body: some View {
    withDependencies { dependencies in
      dependencies.locale = locale
    } operation: {
      Text(state.localized)
    }
  }
}
