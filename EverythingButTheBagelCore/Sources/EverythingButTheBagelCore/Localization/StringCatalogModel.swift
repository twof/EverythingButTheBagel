import Foundation

struct StringCatalogModel: Codable {
  let sourceLanguage: String
  let strings: [String: StringCatalogString]
  let version: String
}

struct StringCatalogString: Codable {
  let comment: String?
  let localizations: [String: StringCatalogLocalization]?
}

struct StringCatalogLocalization: Codable {
  let stringUnit: StringUnit
}

struct StringUnit: Codable {
  let state: String
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
