import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

@MainActor
class CatFactsTests: XCTestCase {
  func testScroll() async throws {
    let store = TestStore(initialState: CatFactsListViewModelReducer.State()) {
      CatFactsListViewModelReducer()
    }

    let scrollPosition: Float = 10.0

    await store.send(.scroll(position: scrollPosition)) { state in
      state.scrollPosition = scrollPosition
    }
  }
}
