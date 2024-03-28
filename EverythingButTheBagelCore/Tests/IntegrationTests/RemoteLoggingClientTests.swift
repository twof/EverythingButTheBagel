@testable import EverythingButTheBagelCore
import XCTest
import Dependencies

class RemoteLoggingClientTests: XCTestCase {
  func testSetup() {
    let client = DependencyValues.live.remoteLoggingClient
    client.setup()
  }

  // Shouldn't do anything. Only creates a breadcrumb in sentry
  func testLogInfo() {
    let client = DependencyValues.live.remoteLoggingClient
    client.setup()

    client.log(level: .info(message: "test message"), category: "Test Category")
  }

  // Shouldn't do anything. Only creates a breadcrumb in Sentry.
  func testLogWarning() {
    let client = DependencyValues.live.remoteLoggingClient
    client.setup()

    client.log(level: .warning(message: "test message"), category: "Test Category")
  }

  // Actually sends an event to Sentry
  func testLogError() {
    let client = DependencyValues.live.remoteLoggingClient
    client.setup()

    client.log(level: .error(error: ExampleError.malformedJson.toEquatableError()), category: "Test Category")
  }

  // Actually sends an event to Sentry after attaching breadcrumbs
  func testLogErrorAfterBreadcrumbs() {
    let client = DependencyValues.live.remoteLoggingClient
    client.setup()

    client.log(level: .info(message: "test message"), category: "Test Category")
    client.log(level: .warning(message: "test message"), category: "Test Category")
    client.log(level: .error(error: ExampleError.malformedJson.toEquatableError()), category: "Test Category")
  }
}
