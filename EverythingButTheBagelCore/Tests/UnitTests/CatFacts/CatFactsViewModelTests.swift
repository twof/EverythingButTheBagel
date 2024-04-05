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
      state.status = .loaded(data: facts.map(CatFactViewModel.init(model:)).toIdentifiedArray)
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
      state.status = .loaded(data: facts.map(CatFactViewModel.init(model:)).toIdentifiedArray)
    }

    let newFacts = [
      CatFactModel(fact: "Some cats are big"),
      CatFactModel(fact: "Some cats are very small")
    ]

    await store.send(.newFacts(newFacts)) { state in
      state.status = .loaded(data: newFacts.map(CatFactViewModel.init(model:)).toIdentifiedArray)
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

  @MainActor
  func testIsLoading() async throws {
    let store = TestStore(initialState: CatFactsListViewModelReducer.State()) {
      CatFactsListViewModelReducer()
    }

    await store.send(.isLoading(true)) { state in
      /*
       When loading, display a loading indicator
       If there is no content, show shimmering placeholders
       If there is content, just show the loading indicator

       I need some way to get rid of placeholders when loading completes
        two lists, one of placeholders and one of data,
        when loading, display placeholders contatenated with data
        only apply shimmer to placeholders
       */
      state.status = .loading(data: [], placeholders: .placeholders)
    }

    await store.send(.isLoading(false)) { state in
      state.status = .loaded(data: [])
    }
  }
}
