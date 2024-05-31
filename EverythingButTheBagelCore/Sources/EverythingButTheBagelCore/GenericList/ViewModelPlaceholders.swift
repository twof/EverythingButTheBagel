import IdentifiedCollections

public protocol ViewModelPlaceholders {
  static var placeholders: [Self] { get }
}

public extension IdentifiedArrayOf where Element: ViewModelPlaceholders & Identifiable {
  static var placeholders: IdentifiedArrayOf<Element> {
    Element.placeholders.toIdentifiedArray
  }
}
