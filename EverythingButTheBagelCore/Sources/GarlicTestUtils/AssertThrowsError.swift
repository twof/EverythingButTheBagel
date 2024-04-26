import XCTest
import EverythingButTheBagelCore

public func assertThrowsError(closure: () async throws -> Void, errorMatches: (EquatableError) -> Bool) async {
  do {
    try await closure()
    XCTFail("Expected error")
  } catch let caughtError {
    guard errorMatches(caughtError.toEquatableError()) else {
      return XCTFail("Unexpected error \(caughtError.localizedDescription)")
    }
  }
}
