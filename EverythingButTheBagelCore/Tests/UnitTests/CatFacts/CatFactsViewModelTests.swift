import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

class CatFactsViewModelTests: XCTestCase {
  @MainActor
  func testScroll() async throws {
    let store = TestStore(initialState: CatFactsListViewModelReducer.State()) {
      CatFactsListViewModelReducer()
    }

    let scrollPosition: Double = 10.0

    await store.send(.scroll(position: scrollPosition)) { state in
      state.scrollPosition = scrollPosition
    }
  }

  @MainActor
  func testNewFacts() async throws {
    let store = TestStore(initialState: CatFactsListViewModelReducer.State()) {
      CatFactsListViewModelReducer()
    }

    let facts = [
      CatFactModel(fact: "Some cats are big"),
      CatFactModel(fact: "Some cats are small")
    ]

    await store.send(.newFacts(facts)) { state in
      state.facts = IdentifiedArray(uniqueElements: facts.map(CatFactViewModel.init(model:)))
    }
  }

  @MainActor
  func testEmptyNewFacts() async throws {
    let store = TestStore(initialState: CatFactsListViewModelReducer.State()) {
      CatFactsListViewModelReducer()
    }

    let facts: [CatFactModel] = []

    // No change expected
    await store.send(.newFacts(facts))
  }

  @MainActor
  func testModifyFacts() async throws {
    let store = TestStore(initialState: CatFactsListViewModelReducer.State()) {
      CatFactsListViewModelReducer()
    }

    let facts = [
      CatFactModel(fact: "Some cats are big"),
      CatFactModel(fact: "Some cats are small")
    ]

    await store.send(.newFacts(facts)) { state in
      state.facts = IdentifiedArray(uniqueElements: facts.map(CatFactViewModel.init(model:)))
    }

    let newFacts = [
      CatFactModel(fact: "Some cats are big"),
      CatFactModel(fact: "Some cats are very small")
    ]

    await store.send(.newFacts(newFacts)) { state in
      state.facts = IdentifiedArray(uniqueElements: newFacts.map(CatFactViewModel.init(model:)))
    }
  }

  @MainActor
  func testTask() async throws {
    let store = TestStore(initialState: CatFactsListViewModelReducer.State()) {
      CatFactsListViewModelReducer()
    }

    // No change expected. Task is a delegate action.
    await store.send(.delegate(.task))
  }
}
