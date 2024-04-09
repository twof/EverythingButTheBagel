import ComposableArchitecture
import XCTest
@testable import EverythingButTheBagelCore
import FunctionSpy

class CollectionUtilsTests: XCTestCase {
  func testBackProducesNegativeIndexElementInLongList() {
    let list = [1, 2, 3, 4, 5, 6, 7]

    XCTAssertEqual(list[back: 0], 7)
    XCTAssertEqual(list[back: 2], 5)
  }

  func testBackProducesFirstItemInShortList() {
    let list = [1, 2]

    XCTAssertEqual(list[back: 0], 2)
    XCTAssertEqual(list[back: 5], 1)
  }

  func testBackProducesNilInEmptyList() {
    let list = [Int]()

    XCTAssertEqual(list[back: 0], nil)
    XCTAssertEqual(list[back: 5], nil)
  }
}
