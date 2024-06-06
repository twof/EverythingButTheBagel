import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture
import Foundation

class LocalizationTests: XCTestCase {
  func testStringLocalizationExists() throws {
    let state = LocalizedTextState(
      text: String(
        localized: "No facts here! Pull to refresh to check again.",
        bundle: .module,
        comment: "Message to let the user know that there are no list items, but not due to an error."
      ),
      stringCatalogLocation: .stringCatalog()
    )

    // Check that english localization matches original
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "en")
      dependencies.stringCatalog = { _ in .mock }
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }

    // Check that spanish localization does not match
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "es")
      dependencies.stringCatalog = { _ in .mock }
    } operation: {
      XCTAssertNotEqual(state.localized, state.text)
    }
  }

  func testStringLocalizationDoesNotExist() throws {
    let state = LocalizedTextState(
      text: "Something that doesn't exist",
      stringCatalogLocation: .stringCatalog()
    )

    // Check that english localization matches original
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "en")
      dependencies.stringCatalog = { _ in .mock }
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }

    // Check that spanish localization does not match
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "es")
      dependencies.stringCatalog = { _ in .mock }
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }
  }

  func testStringExistsButLocalizationDoesnt() throws {
    let state = LocalizedTextState(
      text: String(
        localized: "No facts here! Pull to refresh to check again.",
        bundle: .module,
        comment: "Message to let the user know that there are no list items, but not due to an error."
      ),
      stringCatalogLocation: .stringCatalog()
    )

    // Check that english localization matches original
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "en")
      dependencies.stringCatalog = { _ in .mock }
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }

    // Check that spanish localization does not match
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "fake locale")
      dependencies.stringCatalog = { _ in .mock }
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }
  }
}
