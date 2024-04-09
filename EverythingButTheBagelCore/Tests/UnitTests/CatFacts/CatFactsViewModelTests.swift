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
  func testNewFactsReset() async throws {
    let facts = [
      CatFactModel(fact: "Some cats are big"),
      CatFactModel(fact: "Some cats are small")
    ]

    let store = TestStore(
      initialState: CatFactsListViewModelReducer.State(
        status: .loaded(data: facts.map(CatFactViewModel.init(model:)).toIdentifiedArray)
      )
    ) {
      CatFactsListViewModelReducer()
    }

    let newFacts = [
      CatFactModel(fact: "Some cats are really big"),
      CatFactModel(fact: "Some cats are really small")
    ]

    await store.send(.newFacts(newFacts, strategy: .reset)) { state in
      state.status = .loaded(data: newFacts.map(CatFactViewModel.init(model:)).toIdentifiedArray)
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
      state.status = .loaded(data: state.status.data + newFacts.map(CatFactViewModel.init(model:)).toIdentifiedArray)
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
       If there is content, just show the loading indicator + 1 placeholder
       */
      state.status = .loading(data: [], placeholders: .placeholders)
    }

    await store.send(.isLoading(false)) { state in
      state.status = .loaded(data: [])
    }
  }

  func testLoadingElement() {
    let status = Status.loaded(
      data: [.init(fact: "1"), .init(fact: "2"), .init(fact: "3"), .init(fact: "4")]
    )
    XCTAssertEqual(status.loadingElement, .init(fact: "2"))
  }

  func testSinglePlaceholderOnManyElements() {
    // We keep a single placeholder at the bottom of the list to indicate loading
    let status = Status.loading(
      data: (0...20).map { CatFactViewModel(fact: "\($0)") }.toIdentifiedArray,
      placeholders: .placeholders
    )
    XCTAssertEqual(status.placeholders.count, 1)
  }

  func testAFewPlaceholdersOnLessElements() {
    // We keep a more placeholders to fill up the screen during loading
    let status = Status.loading(
      data: [.init(fact: "1"), .init(fact: "2"), .init(fact: "3")],
      placeholders: .placeholders
    )
    XCTAssertEqual(status.placeholders.count, 4)
  }

  func testNoPlaceholdersWhenNotLoading() {
    // We keep a single placeholder at the bottom of the list to indicate loading
    let status = Status.loaded(data: [.init(fact: "1"), .init(fact: "2"), .init(fact: "3")])
    XCTAssertEqual(status.placeholders.count, 0)
  }

  func testIsLoadingState() {
    let loadedState = CatFactsListViewModelReducer.State(status: .loaded(data: []))
    XCTAssertFalse(loadedState.isLoading)

    let loadingState = CatFactsListViewModelReducer.State(
      status: .loading(data: [], placeholders: [])
    )
    XCTAssertTrue(loadingState.isLoading)
  }
}
