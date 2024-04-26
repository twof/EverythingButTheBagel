import Foundation

public extension Collection {
  subscript(back index: Int) -> Iterator.Element? {
    guard !isEmpty else { return nil }

    let backBy = index + 1

    if self.count < index {
      return self.first
    }

    return self[self.index(self.endIndex, offsetBy: -backBy)]
  }
}
