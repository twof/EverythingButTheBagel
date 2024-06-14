import Foundation
import Dependencies

public struct LocalizedTextState: Codable, Equatable, Sendable {
  @Dependency(\.locale) var locale: Locale
  @Dependency(\.stringCatalog) var stringCatalogClient
  var text: String
  var stringCatalogLocation: URL

  enum CodingKeys: CodingKey {
    case text
    case stringCatalogLocation
  }

  public init(text: String, stringCatalogLocation: URL) {
    self.text = text
    self.stringCatalogLocation = stringCatalogLocation
  }

  /// Returns the string localized to the current locale, or the original string if a
  /// localization doesn't exist
  public var localized: String {
    let stringCatalog = stringCatalogClient(stringCatalogLocation)
    let localizedString = stringCatalog.strings[text]?.localizations?[locale.identifier]?.stringUnit.value

    return localizedString ?? text
  }

  public static func == (left: LocalizedTextState, right: LocalizedTextState) -> Bool {
    left.text == right.text && left.stringCatalogLocation == right.stringCatalogLocation
  }
}

/// Load and cache string catalogs from disk
/// Manually parses out the string catalog to give us tighter control over String localization in previews
/// and tests.
///
/// If we don't do this, it's not possible to control copy from our view models while also controlling
/// locale in previews and tests.
struct StringCatalogClient: DependencyKey {
  static var catalogCache: [URL: StringCatalogModel] = [:]

  static var liveValue: (URL) -> StringCatalogModel = { location in
    if let cachedCatalog = catalogCache[location] {
      return cachedCatalog
    }

    let data = try! Data(contentsOf: location)
    let catalog = try! JSONDecoder().decode(StringCatalogModel.self, from: data)
    catalogCache[location] = catalog

    return catalog
  }

  static var previewValue: (URL) -> StringCatalogModel = unimplemented("string catalog")
}

extension DependencyValues {
  var stringCatalog: (URL) -> StringCatalogModel {
    get { self[StringCatalogClient.self] }
    set { self[StringCatalogClient.self] = newValue }
  }
}
