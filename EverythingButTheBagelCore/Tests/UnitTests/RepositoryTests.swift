import XCTest
@testable import EverythingButTheBagelCore
import Dependencies
import FunctionSpy
import GarlicTestUtils

class RepositoryTests: XCTestCase {
  let testResponse = ResponseModel(fact: "This is a test")

  @MainActor
  func testMakeRequestHappyPath() async throws {
    try await withMockRepository { _, repository in
      let response = try await repository(.init(url: .mock))
      XCTAssertEqual(response, testResponse)
    }
  }

  @MainActor
  func testMakeRequestInvalidJsonData() async throws {
    try await withMockRepository(responseData: Data()) { _, repository in
      await assertThrowsError {
        _ = try await repository(.init(url: .mock))
      } errorMatches: { error in
        if case let DecodingError.dataCorrupted(context) = error.base {
          return context.debugDescription == "The given data was not valid JSON."
        }

        return false
      }
    }
  }

  @MainActor
  func testMakeRequestMissingURL() async throws {
    try await withMockRepository { _, repository in
      await assertThrowsError {
        var request = URLRequest(url: .mock)
        request.url = nil
        _ = try await repository(request)
      } errorMatches: { error in
        return error == NetworkRequestError
          .malformedRequest(message: "URLRequest was missing a url")
          .toEquatableError()
      }
    }
  }

  @MainActor
  func testMakeRequestNonHTTPResponse() async throws {
    try await withMockRepository(response: URLResponse()) { _, repository in
      await assertThrowsError {
        _ = try await repository(.init(url: .mock))
      } errorMatches: { error in
        return error == NetworkRequestError.transportError(
          NetworkRequestError
            .malformedResponse(message: "Response was not an HTTPURLResponse")
            .toEquatableError()
        )
        .toEquatableError()
      }
    }
  }

  @MainActor
  func testMakeRequestNon200Status() async throws {
    let response = HTTPURLResponse.fail(url: URL.mock.absoluteString)
    try await withMockRepository(
      response: response
    ) { _, repository in
      await assertThrowsError {
        _ = try await repository(.init(url: .mock))
      } errorMatches: { error in
        return error == NetworkRequestError.serverError(statusCode: response.statusCode)
        .toEquatableError()
      }
    }
  }

  private func withMockRepository(
    responseData: Data? = nil,
    response: URLResponse? = nil,
    closure: (
      Spy1<URLRequest>,
      (URLRequest) async throws -> ResponseModel
    ) async throws -> Void
  ) async throws {
    let responseData = try responseData ?? JSONEncoder().encode(testResponse)
    let repository = Repository<ResponseModel>.liveValue
    let urlResponse = response ?? HTTPURLResponse.success(url: URL.mock.absoluteString)

    let (networkSpy, networkFn) = spy({ (_: URLRequest) in
      return (responseData, urlResponse)
    })

    try await withDependencies { dependencies in
      dependencies.networkRequest = networkFn
    } operation: {
      try await closure(networkSpy, repository)
    }
  }
}
