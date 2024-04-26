import SwiftUI
import EverythingButTheBagelCore

@ViewBuilder public func emptyListView(localizedText: LocalizedTextState) -> some View {
  VStack(spacing: 15) {
    Image(systemName: "questionmark.circle.fill")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 50)
      .foregroundStyle(.red)

    LocalizedText(localizedText)
      .font(.title3)
      .multilineTextAlignment(.center)
  }
  .padding()
}

private func mock() -> some View {
  let file = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "CatFactsCore")
      .appending(path: "Sources")
      .appending(path: "CatFactsCore")
      .appending(path: "Localizable.xcstrings")

  return emptyListView(
    localizedText: LocalizedTextState(
      text: "No facts here! Pull to refresh to check again.",
      stringCatalogLocation: file
    )
  )
  .environment(\.locale, .init(identifier: "es"))
}

#Preview {
  mock()
}
