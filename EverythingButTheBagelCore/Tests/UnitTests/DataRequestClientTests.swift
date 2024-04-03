import ComposableArchitecture
import XCTest
@testable import EverythingButTheBagelCore
import FunctionSpy

// Since we're testing a live dependency these tests would normally be in the integration test
// suite, but this specific dependency just combines a few other dependencies and doesn't make
// any network requests itself. If it ever does start doing work itself,
// these tests should be moved.
// TODO: A lot of preamble in these tests. I want a way to simplify them.
class DataRequestClientTests: XCTestCase {
  @MainActor
  func testRequestWithValidURL() async throws {
    let response = ResponseModel(fact: "this is a response")
    let urlString = "https://catfacts.ninja"

    await withDependencies { dependencies in
      // Returns `returnVal` encoded to Data
      dependencies.networkRequest = { _ in
        do {
          let data = try JSONEncoder().encode(response)
          return (data, HTTPURLResponse.success(url: urlString))
        } catch {
          XCTFail("Unexpected error \(error)")
          return (Data(), URLResponse())
        }
      }
      dependencies.cacheConfiguration = { _, _ in }
    } operation: {
      let client = DataRequestClient<ResponseModel>.liveValue
      do {
        let returnedResponse = try await client.request(
          urlString: urlString,
          cachePolicy: .reloadIgnoringLocalCacheData
        )

        XCTAssertEqual(response, returnedResponse)
      } catch {
        XCTFail("Unexpected error \(error.localizedDescription)")
      }
    }
  }

  func testRequestWithInvalidURL() async throws {
    let response = ResponseModel(fact: "this is a response")
    // Creating an invalid URL according to URL.init(string:) is more difficult than I thought
    // The only time I got it to return nil was with an empty string
    let urlString = ""

    await withDependencies { dependencies in
      // Returns `returnVal` encoded to Data
      dependencies.networkRequest = { _ in
        do {
          let data = try JSONEncoder().encode(response)
          return (data, HTTPURLResponse.success(url: urlString))
        } catch {
          XCTFail("Unexpected error \(error)")
          return (Data(), URLResponse())
        }
      }
      dependencies.cacheConfiguration = { _, _ in }
    } operation: {
      let failureExpectation = expectation(description: "Method should throw an error")
      let client = DataRequestClient<ResponseModel>.liveValue
      do {
        // Error expected. We don't care about the response.
        _ = try await client.request(
          urlString: urlString,
          cachePolicy: .reloadIgnoringLocalCacheData
        )

        XCTFail("Expected method to throw")
      } catch let NetworkRequestError.malformedRequest(message) {
        XCTAssertEqual(message, "Attempted to connect to a malformed URL: \(urlString)")
        failureExpectation.fulfill()
      } catch {
        XCTFail("Unexpected error \(error.localizedDescription)")
      }

      await fulfillment(of: [failureExpectation])
    }
  }
}
