import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture
import GarlicTestUtils

class ListFeatureBaseTests: XCTestCase {
  @MainActor
  func testUpdateFactsOnResponse() async throws {
    let response = TestResponseModel.mock
    let store = TestStore(initialState: .init()) {
      Feature.test
    }

    await store.send(.dataSource(.delegate(.response(response)))) { state in
      state.nextPageUrl = response.nextPageUrl?.appending(queryItems: [.init(name: "limit", value: "40")])
      state.lastResponse = response.modelList
    }

    await store.receive(.viewModel(.newResponse(response.data.vms))) { state in
      state.viewModel.status = .loaded(
        data: response.data.map(ViewModel.init(model:)).toIdentifiedArray
      )
    }

    // Loading starts out false, no change expected
    await store.receive(.viewModel(.isLoading(false)))
  }

  @MainActor
  func testFetchOnTask() async throws {
    let store = TestStore(initialState: .init()) {
      Feature.test
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<TestResponseModel>.self] = .init(request: { _, _ in TestResponseModel.mock })
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
      initialState: Feature.State(viewModel: .init(status: .loaded(data: .placeholders)))
    ) {
      Feature.test
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<TestResponseModel>.self] = .init(request: { _, _ in TestResponseModel.mock })
    }

    await store.send(.viewModel(.delegate(.task)))
  }

  @MainActor
  func testOnError() async throws {
    let reducer = Feature.test
    let store = TestStore(
      initialState: Feature.State()
    ) {
      reducer
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<TestResponseModel>.self] = .init(request: { _, _ in TestResponseModel.mock })
      dependencies.uuid = .incrementing
    }

    await store.send(.dataSource(.delegate(.error(ExampleError.malformedJson.toEquatableError(), sourceId: reducer.baseUrl, errorId: .init(0)))))
    await store.receive(\.viewModel.isLoading)
  }

  @MainActor
  func testNextPageWhenPageExists() async throws {
    let store = TestStore(
      initialState: Feature.State(nextPageUrl: .mock)
    ) {
      Feature.test
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<TestResponseModel>.self] = .init(request: { _, _ in TestResponseModel.mock })
    }

    store.exhaustivity = .off

    await store.send(.viewModel(.delegate(.nextPage)))
    await store.receive(\.dataSource.fetch)
  }

  @MainActor
  func testNextPageWhenPageDoesNotExist() async throws {
    let store = TestStore(
      initialState: Feature.State()
    ) {
      Feature.test
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<TestResponseModel>.self] = .init(request: { _, _ in TestResponseModel.mock })
    }

    store.exhaustivity = .off

    await store.send(.viewModel(.delegate(.nextPage)))
  }

  @MainActor
  func testFetchOnRefresh() async throws {
    let store = TestStore(
      initialState: Feature.State(nextPageUrl: nil)
    ) {
      Feature.test
    } withDependencies: { dependencies in
      dependencies[DataRequestClient<TestResponseModel>.self] = .init(request: { _, _ in TestResponseModel.mock })
    }

    store.exhaustivity = .off

    await store.send(.viewModel(.delegate(.refresh)))
    await store.receive(\.refreshDataSource.fetch)
    await store.receive(.refreshDataSource(.delegate(.response(TestResponseModel.mock))))
    await store.receive(.viewModel(.newResponse(TestResponseModel.mock.data.vms, strategy: .reset)))
  }
}

typealias Feature = ListFeatureBase<ViewModel, TestResponseModel, EmptyPathReducer>

extension Feature {
  static var test: Feature {
    ListFeatureBase().nextPage { response in
      response.nextPageUrl?.appending(queryItems: [.init(name: "limit", value: "40")])
    }
  }
}

extension Feature.State {
  init(nextPageUrl: URL? = nil) {
    self.init(viewModel: .init(), nextPageUrl: nextPageUrl)
  }
}

public extension Feature {
  init() {
    self.init(
      baseUrl: "https://catfact.ninja/facts?page=1&limit=40",
      errorSourceId: "CatFactsDataSource",
      viewModelReducer: .test
    )
  }
}
