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
      state.viewModel.status = .loaded(
        data: response.data.map(CatFactViewModel.init(model:)).toIdentifiedArray
      )
    }

    // Loading starts out false, no change expected
    await store.receive(.viewModel(.isLoading(false)))
  }

  @MainActor
  func testFetchOnTask() async throws {
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

    await store.receive(.viewModel(.isLoading(true))) { state in
      state.viewModel.status = .loading(data: [], placeholders: .placeholders)
    }
  }
}
