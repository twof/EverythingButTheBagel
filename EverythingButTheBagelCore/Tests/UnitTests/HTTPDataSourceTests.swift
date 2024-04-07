import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

class HTTPDataSourceTests: XCTestCase {
  typealias DataSource = HTTPDataSourceReducer<ResponseModel>

  @MainActor
  func testFetchWithValidURL() async throws {
    let responseModel = ResponseModel(fact: "Cats have fur usually")
    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorId: "test")
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
  func testFetchWithErrorResponseRetriesUntilMaxRetries() async throws {
    let error = NetworkRequestError.malformedRequest(message: "Malformed URL")
    let clock = TestClock()
    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorId: "test")
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in
        throw error
      })
      dependencies.continuousClock = clock
    }

    await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 0)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 1
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 1)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 2
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 2)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 3
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 3)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 4
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 4)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 5
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))
  }

  @MainActor
  func testFetchRetriesUntilSuccessfulResponse() async throws {
    let error = NetworkRequestError.malformedRequest(message: "Malformed URL")
    let clock = TestClock()
    var count = 0
    let maxRetries = 5
    let responseModel = ResponseModel(fact: "Cats have fur usually")

    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorId: "test", maxRetries: maxRetries)
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in
        if count < 1 {
          count += 1
          throw error
        }

        return responseModel

      })
      dependencies.continuousClock = clock
    }

    await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 0)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 1
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.response(responseModel)))
  }

  // Cancelled actions shouldn't do retries
  @MainActor
  func testFetchRetriesUntilCanceled() async throws {
    let error = NetworkRequestError.malformedRequest(message: "Malformed URL")
    let clock = TestClock()
    var count = 0
    let maxRetries = 5
    let responseModel = ResponseModel(fact: "Cats have fur usually")

    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorId: "test", maxRetries: maxRetries)
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in
        throw error
      })
      dependencies.continuousClock = clock
    }

    let task = await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError())))

    await task.cancel()
  }
}
