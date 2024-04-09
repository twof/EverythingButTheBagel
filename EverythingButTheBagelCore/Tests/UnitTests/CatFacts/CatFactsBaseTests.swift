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

    await store.send(.dataSource(.delegate(.response(response)))) { state in
      state.nextPage = response.nextPageUrl
    }

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

  @MainActor
  func testDontFetchIfDataAlreadyLoaded() async throws {
    let store = TestStore(
      initialState: CatFactsListBase.State(viewModel: .init(status: .loaded(data: .placeholders)))
    ) {
      CatFactsListBase()
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
    }

    await store.send(.viewModel(.delegate(.task)))
  }

  @MainActor
  func testOnError() async throws {
    let store = TestStore(
      initialState: CatFactsListBase.State()
    ) {
      CatFactsListBase()
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
    }

    await store.send(.dataSource(.delegate(.error(ExampleError.malformedJson.toEquatableError()))))
    await store.receive(\.viewModel.isLoading)
  }

  @MainActor
  func testNextPageWhenPageExists() async throws {
    let store = TestStore(
      initialState: CatFactsListBase.State()
    ) {
      CatFactsListBase()
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
    }

    store.exhaustivity = .off

    await store.send(.viewModel(.delegate(.nextPage)))
    await store.receive(\.dataSource.fetch)
  }

  @MainActor
  func testNextPageWhenPageDoesNotExist() async throws {
    let store = TestStore(
      initialState: CatFactsListBase.State(nextPage: nil)
    ) {
      CatFactsListBase()
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
    }

    store.exhaustivity = .off

    await store.send(.viewModel(.delegate(.nextPage)))
  }

  @MainActor
  func testFetchOnRefresh() async throws {
    let store = TestStore(
      initialState: CatFactsListBase.State(nextPage: nil)
    ) {
      CatFactsListBase()
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
    }

    store.exhaustivity = .off

    await store.send(.viewModel(.delegate(.refresh)))
    await store.receive(\.refreshDataSource.fetch)
    await store.receive(.refreshDataSource(.delegate(.response(CatFactsResponseModel.mock))))
    await store.receive(.viewModel(.newFacts(CatFactsResponseModel.mock.data, strategy: .reset)))
  }
}
