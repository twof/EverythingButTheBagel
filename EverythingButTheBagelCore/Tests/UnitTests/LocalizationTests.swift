import XCTest
@testable import EverythingButTheBagelCore
import ComposableArchitecture

class LocalizationTests: XCTestCase {
  func testStringLocalizationExists() throws {
    let state = CatFactsListViewModelReducer.State().emptyListMessage

    // Check that english localization matches original
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "en")
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }

    // Check that spanish localization does not match
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "es")
    } operation: {
      XCTAssertNotEqual(state.localized, state.text)
    }
  }

  func testStringLocalizationDoesNotExist() throws {
    let state = LocalizedTextState(text: "Something that doesn't exist")

    // Check that english localization matches original
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "en")
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }

    // Check that spanish localization does not match
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "es")
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }
  }

  func testStringExistsButLocalizationDoesnt() throws {
    let state = CatFactsListViewModelReducer.State().emptyListMessage

    // Check that english localization matches original
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "en")
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }

    // Check that spanish localization does not match
    withDependencies { dependencies in
      dependencies.locale = .init(identifier: "fake locale")
    } operation: {
      XCTAssertEqual(state.localized, state.text)
    }
  }
}
