import Foundation

/// Represents the contents of an .xcstrings file
struct StringCatalogModel: Codable {
  /// Locale code
  let sourceLanguage: String
  /// String to list of localizations of that string
  let strings: [String: StringCatalogString]
  let version: String
}

struct StringCatalogString: Codable {
  let comment: String?
  /// Locale codes to localized strings
  let localizations: [String: StringCatalogLocalization]?
}

struct StringCatalogLocalization: Codable {
  let stringUnit: StringUnit
}

struct StringUnit: Codable {
  /// State of the localized string ie translated
  let state: String
  /// Localized string
  let value: String
}

extension StringCatalogModel {
  static let mock = StringCatalogModel(
    sourceLanguage: "en",
    strings: [
      "No facts here! Pull to refresh to check again.": StringCatalogString(
        comment: nil,
        localizations: [
          "es": StringCatalogLocalization(stringUnit: StringUnit(
            state: "translated",
            value: "¡No hay hechos aquí! Tire para actualizar y volver a comprobarlo."
          ))
        ]
      )
    ],
    version: "1.0.0"
  )
}
