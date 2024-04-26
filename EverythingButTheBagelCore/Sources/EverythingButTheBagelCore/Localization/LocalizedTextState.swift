import Foundation
import Dependencies

public struct LocalizedTextState: Codable, Equatable {
  @Dependency(\.locale) var locale: Locale
  var text: String
  let stringCatalogLocation: URL

  /// Manually parses out the string catalog to give us tighter control over String localization
  /// in previews and tests
  var stringCatalog: StringCatalogModel {
    let data = try! Data(contentsOf: self.stringCatalogLocation)
    return try! JSONDecoder().decode(StringCatalogModel.self, from: data)
  }

  enum CodingKeys: CodingKey {
    case text
    case stringCatalogLocation
  }

  public init(text: String, stringCatalogLocation: URL) {
    self.text = text
    self.stringCatalogLocation = stringCatalogLocation

    print(stringCatalogLocation)
  }

  /// Returns the string localized to the current locale, or the original string if a
  /// localization doesn't exist
  public var localized: String {
    stringCatalog.strings[text]?.localizations[locale.identifier]?.stringUnit.value
      ?? text
  }

  public static func == (lhs: LocalizedTextState, rhs: LocalizedTextState) -> Bool {
    lhs.text == rhs.text
  }
}
