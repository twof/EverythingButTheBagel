import Foundation
import Dependencies

public struct LocalizedTextState: Codable, Equatable {
  @Dependency(\.locale) var locale: Locale
  var text: String

  enum CodingKeys: CodingKey {
    case text
  }

  public init(text: String) {
    self.text = text
  }

  /// Returns the string localized to the current locale, or the original string if a localization doesn't exist
  public var localized: String {
    LocalizedTextState.stringCatalog.strings[text]?.localizations[locale.identifier]?.stringUnit.value
      ?? text
  }

  public static func == (lhs: LocalizedTextState, rhs: LocalizedTextState) -> Bool {
    lhs.text == rhs.text
  }
}

extension LocalizedTextState {
  /// Manually parses out the string catalog to give us tighter control over String localization in previews and tests
  static let stringCatalog: StringCatalogModel = {
    let url = URL(fileURLWithPath: #file).deletingLastPathComponent().appending(path: "Localizable.xcstrings")
    let data = try! Data(contentsOf: url)
    return try! JSONDecoder().decode(StringCatalogModel.self, from: data)
  }()
}
