import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

class HTTPDataSourceTests: XCTestCase {
  @MainActor
  func testFetchWithValidURL() async throws {
    let responseModel = ResponseModel(fact: "Cats have fur usually")
    let store = TestStore(initialState: HTTPDataSourceReducer<ResponseModel>.State(), reducer: {
      HTTPDataSourceReducer<ResponseModel>(errorId: "test")
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in responseModel})
    }

    await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.response(responseModel)))
  }

  @MainActor
  func testFetchWithErrorResponse() async throws {
    let error = NetworkRequestError.malformedRequest(message: "Malformed URL")
    let store = TestStore(initialState: HTTPDataSourceReducer<ResponseModel>.State(), reducer: {
      HTTPDataSourceReducer<ResponseModel>(errorId: "test")
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in
        throw error
      })
    }

    await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))
  }
}
