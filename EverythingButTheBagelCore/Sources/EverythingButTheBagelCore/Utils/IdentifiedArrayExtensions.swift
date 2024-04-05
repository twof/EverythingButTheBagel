import IdentifiedCollections

extension Collection where Element: Identifiable {
  public var toIdentifiedArray: IdentifiedArrayOf<Element> {
    IdentifiedArrayOf(uniqueElements: self)
  }
}
