@testable import EverythingButTheBagelCore
import XCTest
import Dependencies
import FunctionSpy

class LoggingClientTests: XCTestCase {
  // Expected to set info breadcrumbs with sentry and print to console
  @MainActor

  func testLogInfo() {
    let testRemoteLoggingClient = RemoteLoggingClient.clientSpy()

    withDependencies { dependencies in
      dependencies.remoteLoggingClient = testRemoteLoggingClient.client
    } operation: {
      let client = DependencyValues.live.loggingClient
      client.setup()

      client.log(level: .info(message: "test message"), category: "Test Category")
    }

    XCTAssertEqual(testRemoteLoggingClient.setupSpy.callCount, 1)
    XCTAssertEqual(testRemoteLoggingClient.logSpy.callCount, 1)
    let firstParams = testRemoteLoggingClient.logSpy.callParams[0]
    XCTAssertEqual(firstParams.0, LogLevel.info(message: "test message"))
    XCTAssertEqual(firstParams.1, "Test Category")
  }

  // Expected to set waring breadcrumbs with sentry and print to console
  @MainActor
  func testLogWarning() {
    let testRemoteLoggingClient = RemoteLoggingClient.clientSpy()
    let category = "Test Category"

    withDependencies { dependencies in
      dependencies.remoteLoggingClient = testRemoteLoggingClient.client
    } operation: {
      let client = DependencyValues.live.loggingClient
      client.setup()

      client.log(level: .warning(message: "test warning"), category: category)
    }

    XCTAssertEqual(testRemoteLoggingClient.setupSpy.callCount, 1)
    XCTAssertEqual(testRemoteLoggingClient.logSpy.callCount, 1)
    let warning = testRemoteLoggingClient.logSpy.callParams[0]
    XCTAssertEqual(warning.0, .warning(message: "test warning"))
    XCTAssertEqual(warning.1, category)
  }

  // Expected to send error to sentry and print to console
  @MainActor
  func testLogError() {
    let testRemoteLoggingClient = RemoteLoggingClient.clientSpy()
    let category = "Test Category"

    withDependencies { dependencies in
      dependencies.remoteLoggingClient = testRemoteLoggingClient.client
    } operation: {
      let client = DependencyValues.live.loggingClient
      client.setup()

      client.log(
        level: .error(error: ExampleError.malformedJson.toEquatableError()),
        category: category
      )
    }

    XCTAssertEqual(testRemoteLoggingClient.setupSpy.callCount, 1)
    XCTAssertEqual(testRemoteLoggingClient.logSpy.callCount, 1)

    let error = testRemoteLoggingClient.logSpy.callParams[0]
    XCTAssertEqual(error.0, .error(error: ExampleError.malformedJson.toEquatableError()))
    XCTAssertEqual(error.1, category)
  }
}

extension RemoteLoggingClient {
  static func clientSpy() -> (
    client: RemoteLoggingClient,
    setupSpy: Spy,
    logSpy: Spy2<LogLevel, String>
  ) {
    let (setupSpy, setupFn) = spy({})
    let (logSpy, logFn) = spy({(_: LogLevel, _: String) in })

    return (
      RemoteLoggingClient(setup: setupFn, log: logFn),
      setupSpy: setupSpy,
      logSpy: logSpy
    )
  }
}
