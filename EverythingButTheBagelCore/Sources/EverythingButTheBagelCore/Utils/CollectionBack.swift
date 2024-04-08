import Foundation

extension Collection {
  subscript(back i: Int) -> Iterator.Element {
    let backBy = i + 1

    return self[self.index(self.endIndex, offsetBy: -backBy)]
  }
}
