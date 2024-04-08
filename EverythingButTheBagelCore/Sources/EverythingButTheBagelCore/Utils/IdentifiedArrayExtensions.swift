import IdentifiedCollections

extension Collection where Element: Identifiable {
  /// Turns a collection into an identified array. If there are any duplicate elements, it will pick one of them at random.
  public var toIdentifiedArray: IdentifiedArrayOf<Element> {
    IdentifiedArrayOf(self, uniquingIDsWith: { $1 })
  }
}
