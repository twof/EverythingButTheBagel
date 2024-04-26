import Foundation

struct StringCatalogModel: Codable {
  let sourceLanguage: String
  let strings: [String: StringCatalogString]
  let version: String
}

struct StringCatalogString: Codable {
  let comment: String?
  let localizations: [String: StringCatalogLocalization]
}

struct StringCatalogLocalization: Codable {
  let stringUnit: StringUnit
}

struct StringUnit: Codable {
  let state: String
  let value: String
}
