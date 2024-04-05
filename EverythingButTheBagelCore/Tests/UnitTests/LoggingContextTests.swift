@testable import EverythingButTheBagelCore
import XCTest
import Dependencies
import FunctionSpy

class LoggingContextTests: XCTestCase {
  @MainActor
  func testLog() throws {
    let logLevel: LogLevel = .info(message: "test_info")

    withTestClient { context, setupSpy, logSpy in
      context.log(logLevel)
      XCTAssertEqual(setupSpy.callCount, 0)
      XCTAssertEqual(logSpy.callCount, 1)
      XCTAssertEqual(logSpy.callParams[0].0, logLevel)
      XCTAssertEqual(logSpy.callParams[0].1, context.loggingCategory)
    }
  }

  @MainActor
  func testLogErrorsNoErrorsThrown() throws {
    try withTestClient { testClient, setupSpy, logSpy in
      let testReturn = "test"
      let retVal = try testClient.logErrors {
        return testReturn
      }

      XCTAssertEqual(testReturn, retVal)
      XCTAssertEqual(setupSpy.callCount, 0)
      // No logging expected because no errors thrown
      XCTAssertEqual(logSpy.callCount, 0)
    }
  }

  @MainActor
  func testLogErrorsErrorsThrown() throws {
    withTestClient { testClient, setupSpy, logSpy in
      let testError = ExampleError.malformedJson

      do {
        try testClient.logErrors {
          throw testError
        }

        XCTFail("Expected method to throw error")
      } catch {
        XCTAssertEqual(error as? ExampleError, ExampleError.malformedJson)
      }

      XCTAssertEqual(setupSpy.callCount, 0)
      // No logging expected because no errors thrown
      XCTAssertEqual(logSpy.callCount, 1)
      XCTAssertEqual(logSpy.callParams[0].0, .error(error: testError.toEquatableError()))
      XCTAssertEqual(logSpy.callParams[0].1, testClient.loggingCategory)
    }
  }

  @MainActor
  func testLogErrorsNoErrorsThrownAsync() async throws {
    try await withTestClient { testClient, setupSpy, logSpy in
      let testReturn = "test"
      let retVal = try await testClient.logErrors {
        // To force async
        await Task {}.value
        return testReturn
      }

      XCTAssertEqual(testReturn, retVal)
      XCTAssertEqual(setupSpy.callCount, 0)
      // No logging expected because no errors thrown
      XCTAssertEqual(logSpy.callCount, 0)
    }
  }

  @MainActor
  func testLogErrorsErrorsThrownAsync() async throws {
    await withTestClient { testClient, setupSpy, logSpy in
      let testError = ExampleError.malformedJson

      do {
        try await testClient.logErrors {
          // To force async
          await Task {}.value
          throw testError
        }

        XCTFail("Expected method to throw error")
      } catch {
        XCTAssertEqual(error as? ExampleError, ExampleError.malformedJson)
      }

      XCTAssertEqual(setupSpy.callCount, 0)
      // No logging expected because no errors thrown
      XCTAssertEqual(logSpy.callCount, 1)
      XCTAssertEqual(logSpy.callParams[0].0, .error(error: testError.toEquatableError()))
      XCTAssertEqual(logSpy.callParams[0].1, testClient.loggingCategory)
    }
  }

  private func withTestClient(closure: (TestLoggingContext, Spy, Spy2<LogLevel, String>) throws -> Void) rethrows {
    let (setupSpy, setupFn) = spy({})
    let (logSpy, logFn) = spy({ (_: LogLevel, _: String) in })

    try withDependencies { dependencies in
      dependencies.loggingClient = LoggingClient(
        setup: setupFn,
        log: logFn
      )
    } operation: {
      try closure(TestLoggingContext(), setupSpy, logSpy)
    }
  }

  private func withTestClient(closure: (TestLoggingContext, Spy, Spy2<LogLevel, String>) async throws -> Void) async rethrows {
    let (setupSpy, setupFn) = spy({})
    let (logSpy, logFn) = spy({ (_: LogLevel, _: String) in })

    try await withDependencies { dependencies in
      dependencies.loggingClient = LoggingClient(
        setup: setupFn,
        log: logFn
      )
    } operation: {
      try await closure(TestLoggingContext(), setupSpy, logSpy)
    }
  }
}

private struct TestLoggingContext: LoggingContext {
  let loggingCategory = "Test"
}
