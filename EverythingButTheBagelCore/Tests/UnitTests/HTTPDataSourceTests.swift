import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

class HTTPDataSourceTests: XCTestCase {
  typealias DataSource = HTTPDataSourceReducer<ResponseModel>

  @MainActor
  func testFetchWithValidURL() async throws {
    let responseModel = ResponseModel(fact: "Cats have fur usually")
    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorSourceId: "test")
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
    let sourceId = "test"
    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorSourceId: sourceId)
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in
        throw error
      })
      dependencies.continuousClock = clock
      dependencies.uuid = .incrementing
    }

    await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 0)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 1,
      requestId: .init(0)
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 1)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 2,
      requestId: .init(0)
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 2)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 3,
      requestId: .init(0)
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 3)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 4,
      requestId: .init(0)
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 4)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 5,
      requestId: .init(0)
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    // TODO: Should send a different error when max retries hit
  }

  @MainActor
  func testFetchRetriesUntilSuccessfulResponse() async throws {
    let error = NetworkRequestError.malformedRequest(message: "Malformed URL")
    let clock = TestClock()
    var count = 0
    let maxRetries = 5
    let responseModel = ResponseModel(fact: "Cats have fur usually")
    let sourceId = "test"

    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorSourceId: sourceId, maxRetries: maxRetries)
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in
        if count < 1 {
          count += 1
          throw error
        }

        return responseModel

      })
      dependencies.continuousClock = clock
      dependencies.uuid = .incrementing
    }

    await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    await clock.advance(by: .milliseconds(DataSource.backoffDuration(retry: 0)))

    await store.receive(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
      retry: 1,
      requestId: .init(0)
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.clearError(sourceId: sourceId, errorId: .init(0))))
    await store.receive(.delegate(.response(responseModel)))
  }

  // Cancelled actions shouldn't do retries
  @MainActor
  func testFetchRetriesUntilCanceled() async throws {
    let error = NetworkRequestError.malformedRequest(message: "Malformed URL")
    let clock = TestClock()
    let maxRetries = 5
    let sourceId = "test"

    let store = TestStore(initialState: DataSource.State(), reducer: {
      DataSource(errorSourceId: sourceId, maxRetries: maxRetries)
    }) { dependencies in
      dependencies[DataRequestClient<ResponseModel>.self] = DataRequestClient(request: { _, _ in
        throw error
      })
      dependencies.continuousClock = clock
      dependencies.uuid = .incrementing
    }

    let task = await store.send(.fetch(
      url: "https://catfact.ninja/facts",
      cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    ))

    // No state change expected from delegates
    await store.receive(.delegate(.error(error.toEquatableError(), sourceId: sourceId, errorId: .init(0))))

    await task.cancel()

    // TODO: We risk not clearing the errors from canceled requests
  }
}
