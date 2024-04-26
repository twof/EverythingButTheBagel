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
    }

    await store.receive(.viewModel(.newResponse(response))) { state in
      state.viewModel.status = .loaded(
        data: response.data.map(ViewModel.init(model:)).toIdentifiedArray
      )
    }

    // Loading starts out false, no change expected
    await store.receive(.viewModel(.isLoading(false)))
  }

//  @MainActor
//  func testFetchOnTask() async throws {
//    let store = TestStore(initialState: .init()) {
//      Feature.catFacts
//    } withDependencies: { dependencies in
//      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
//    }
//
//    // Fetch is going to do a bunch of other work that we don't care about
//    // Already covered in other tests
//    store.exhaustivity = .off
//
//    await store.send(.viewModel(.delegate(.task)))
//    await store.receive(\.dataSource.fetch)
//
//    await store.receive(.viewModel(.isLoading(true))) { state in
//      state.viewModel.status = .loading(data: [], placeholders: .placeholders)
//    }
//  }
//
//  @MainActor
//  func testDontFetchIfDataAlreadyLoaded() async throws {
//    let store = TestStore(
//      initialState: CatFactsListBase.State(viewModel: .init(status: .loaded(data: .placeholders)))
//    ) {
//      CatFactsListBase()
//    } withDependencies: { dependencies in
//      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
//    }
//
//    await store.send(.viewModel(.delegate(.task)))
//  }
//
//  @MainActor
//  func testOnError() async throws {
//    let reducer = CatFactsListBase()
//    let store = TestStore(
//      initialState: CatFactsListBase.State()
//    ) {
//      reducer
//    } withDependencies: { dependencies in
//      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
//      dependencies.uuid = .incrementing
//    }
//
//    await store.send(.dataSource(.delegate(.error(ExampleError.malformedJson.toEquatableError(), sourceId: reducer.baseUrl, errorId: .init(0)))))
//    await store.receive(\.viewModel.isLoading)
//  }
//
//  @MainActor
//  func testNextPageWhenPageExists() async throws {
//    let store = TestStore(
//      initialState: CatFactsListBase.State(nextPageUrl: .mock)
//    ) {
//      CatFactsListBase()
//    } withDependencies: { dependencies in
//      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
//    }
//
//    store.exhaustivity = .off
//
//    await store.send(.viewModel(.delegate(.nextPage)))
//    await store.receive(\.dataSource.fetch)
//  }
//
//  @MainActor
//  func testNextPageWhenPageDoesNotExist() async throws {
//    let store = TestStore(
//      initialState: CatFactsListBase.State()
//    ) {
//      CatFactsListBase()
//    } withDependencies: { dependencies in
//      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
//    }
//
//    store.exhaustivity = .off
//
//    await store.send(.viewModel(.delegate(.nextPage)))
//  }
//
//  @MainActor
//  func testFetchOnRefresh() async throws {
//    let store = TestStore(
//      initialState: CatFactsListBase.State(nextPageUrl: nil)
//    ) {
//      CatFactsListBase()
//    } withDependencies: { dependencies in
//      dependencies[DataRequestClient<CatFactsResponseModel>.self] = .init(request: { _, _ in CatFactsResponseModel.mock })
//    }
//
//    store.exhaustivity = .off
//
//    await store.send(.viewModel(.delegate(.refresh)))
//    await store.receive(\.refreshDataSource.fetch)
//    await store.receive(.refreshDataSource(.delegate(.response(CatFactsResponseModel.mock))))
//    await store.receive(.viewModel(.newResponse(CatFactsResponseModel.mock, strategy: .reset)))
//  }
}

typealias Feature = ListFeatureBase<TestViewModelReducer, TestResponseModel>

extension Feature {
  static var test: Feature {
    ListFeatureBase().nextPage { response in
      response.nextPageUrl?.appending(queryItems: [.init(name: "limit", value: "40")])
    }
  }
}

extension Feature.State {
  init() {
    self.init(viewModel: .init())
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
