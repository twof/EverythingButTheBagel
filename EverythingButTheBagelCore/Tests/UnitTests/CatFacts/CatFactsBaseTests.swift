import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

class CatFactsBaseTests: XCTestCase {
  @MainActor
  func testUpdateFactsOnResponse() async throws {
    let response = CatFactsResponseModel.mock
    let store = TestStore(initialState: CatFactsListBase.State()) {
      CatFactsListBase()
    }

    await store.send(.dataSource(.delegate(.response(response))))
    await store.receive(.viewModel(.newFacts(response.data))) { state in
      state.viewModel.facts = response.data.map(CatFactViewModel.init(model:)).toIdentifiedArray
    }
  }

  @MainActor
  func testFetchOnTask() async throws {
    let response = CatFactsResponseModel(currentPage: 0, data: [.init(fact: "first fact"), .init(fact: "second fact")], nextPageUrl: nil)
    let store = TestStore(initialState: CatFactsListBase.State()) {
      CatFactsListBase()
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
    }

    // Fetch is going to do a bunch of other work that we don't care about
    // Already covered in other tests
    store.exhaustivity = .off

    await store.send(.viewModel(.delegate(.task)))
    await store.receive(\.dataSource.fetch)
  }
}

extension Collection where Element: Identifiable {
  var toIdentifiedArray: IdentifiedArrayOf<Element> {
    IdentifiedArrayOf(uniqueElements: self)
  }
}
