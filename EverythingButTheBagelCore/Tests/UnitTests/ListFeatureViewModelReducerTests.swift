import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

class ListFeatureViewModelReducerTests: XCTestCase {
  @MainActor
  func testScroll() async throws {
    let store = TestStore(initialState: TestViewModelReducer.State(emptyListMessage: LocalizedTextState(text: "", stringCatalogLocation: .mock))) {
      TestViewModelReducer.test
    }

    let scrollPosition: Double = 10.0

    await store.send(.scroll(position: scrollPosition)) { state in
      state.scrollPosition = scrollPosition
    }
  }

  @MainActor
  func testNewFacts() async throws {
    let store = TestStore(initialState: TestViewModelReducer.State()) {
      TestViewModelReducer.test
    }

    let facts = [
      Model(fact: "Some cats are big"),
      Model(fact: "Some cats are small")
    ]

    await store.send(.newResponse(facts.vms)) { state in
      state.status = .loaded(data: facts.map(ViewModel.init(model:)).toIdentifiedArray)
    }
  }

  @MainActor
  func testNewFactsReset() async throws {
    let facts = [
      Model(fact: "Some cats are big"),
      Model(fact: "Some cats are small")
    ]

    let store = TestStore(
      initialState: TestViewModelReducer.State(
        status: .loaded(data: facts.map(ViewModel.init(model:)).toIdentifiedArray)
      )
    ) {
      TestViewModelReducer.test
    }

    let newFacts = [
      Model(fact: "Some cats are really big"),
      Model(fact: "Some cats are really small")
    ]

    await store.send(.newResponse(newFacts.vms, strategy: .reset)) { state in
      state.status = .loaded(data: newFacts.map(ViewModel.init(model:)).toIdentifiedArray)
    }
  }

  @MainActor
  func testEmptyNewFacts() async throws {
    let store = TestStore(initialState: TestViewModelReducer.State()) {
      TestViewModelReducer.test
    }

    // No change expected
    await store.send(.newResponse([]))
  }

  @MainActor
  func testModifyFacts() async throws {
    let store = TestStore(initialState: TestViewModelReducer.State()) {
      TestViewModelReducer.test
    }

    let facts = [
      Model(fact: "Some cats are big"),
      Model(fact: "Some cats are small")
    ]

    await store.send(.newResponse(facts.vms)) { state in
      state.status = .loaded(data: facts.map(ViewModel.init(model:)).toIdentifiedArray)
    }

    let newFacts = [
      Model(fact: "Some cats are big"),
      Model(fact: "Some cats are very small")
    ]

    await store.send(.newResponse(newFacts.vms)) { state in
      state.status = .loaded(data: state.status.data + newFacts.map(ViewModel.init(model:)).toIdentifiedArray)
    }
  }

  @MainActor
  func testTask() async throws {
    let store = TestStore(initialState: TestViewModelReducer.State()) {
      TestViewModelReducer.test
    }

    // No change expected. Task is a delegate action.
    await store.send(.delegate(.task))
  }

  @MainActor
  func testIsLoading() async throws {
    let store = TestStore(initialState: TestViewModelReducer.State()) {
      TestViewModelReducer.test
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
    let status = ListViewModelStatus<ViewModel>.loaded(
      data: [.init(fact: "1"), .init(fact: "2"), .init(fact: "3"), .init(fact: "4")]
    )
    XCTAssertEqual(status.loadingElement, .init(fact: "2"))
  }

  func testSinglePlaceholderOnManyElements() {
    // We keep a single placeholder at the bottom of the list to indicate loading
    let status = ListViewModelStatus.loading(
      data: (0...20).map { ViewModel(fact: "\($0)") }.toIdentifiedArray,
      placeholders: .placeholders
    )
    XCTAssertEqual(status.placeholders.count, 1)
  }

  func testAFewPlaceholdersOnLessElements() {
    // We keep a more placeholders to fill up the screen during loading
    let status = ListViewModelStatus<ViewModel>.loading(
      data: [.init(fact: "1"), .init(fact: "2"), .init(fact: "3")],
      placeholders: .placeholders
    )
    XCTAssertEqual(status.placeholders.count, 4)
  }

  func testNoPlaceholdersWhenNotLoading() {
    // We keep a single placeholder at the bottom of the list to indicate loading
    let status = ListViewModelStatus<ViewModel>.loaded(data: [.init(fact: "1"), .init(fact: "2"), .init(fact: "3")])
    XCTAssertEqual(status.placeholders.count, 0)
  }

  func testIsLoadingState() {
    let loadedState = TestViewModelReducer.State(status: .loaded(data: []))
    XCTAssertFalse(loadedState.isLoading)

    let loadingState = TestViewModelReducer.State(
      status: .loading(data: [], placeholders: [])
    )
    XCTAssertTrue(loadingState.isLoading)
  }
}

typealias TestViewModelReducer = ListFeatureViewModelReducer<ViewModel, EmptyPathReducer>

struct ViewModel: Codable, Identifiable, Equatable {
  var id: String { fact }
  let fact: String
}

extension ViewModel: ViewModelConvertable {
  init(model: Model) {
    self.fact = model.fact
  }
}

extension ViewModel: ViewModelPlaceholders {
  static let placeholders = (0..<20).map {
    ViewModel(
      fact: "Example of a long fact Example of a long fact Example of a long fact"
      + "Example of a long fact Example of a long fact Example of a long fact Example of a long"
      + "fact Example of a long fact \($0)"
    )
  }
}

struct Model: Codable, Equatable, Identifiable {
  var id: String { fact }
  let fact: String
}

extension Array<Model> {
  var vms: [ViewModel] {
    self.map(ViewModel.init(model:))
  }
}

struct TestResponseModel: Codable, Equatable {
  let data: [Model]
  let nextPageUrl: URL?

  init(data: [Model] = [], nextPageUrl: URL? = nil) {
    self.data = data
    self.nextPageUrl = nextPageUrl
  }
}

extension TestResponseModel: ListResponse {
  var modelList: [Model] {
    data
  }
}

extension TestResponseModel {
  public static let mock = TestResponseModel(
    data: [.init(fact: "first fact"), .init(fact: "second fact")],
    nextPageUrl: URL(string: "https://catfact.ninja/facts?page=2")
  )
}

extension TestViewModelReducer.State {
  init(status: ListViewModelStatus<Self.ViewModel> = .loaded(data: [])) {
    self.init(
      status: status,
      emptyListMessage: .init(text: "something", stringCatalogLocation: .mock)
    )
  }
}

extension TestViewModelReducer {
  static var test: TestViewModelReducer {
    ListFeatureViewModelReducer()
  }
}
