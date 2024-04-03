import Foundation
import XCTest

extension HTTPURLResponse {
  static func success(url: String) -> HTTPURLResponse {
    guard let url = URL(string: url) else {
      XCTFail("Couldn't cast string to URL")
      return HTTPURLResponse()
    }

    guard let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    ) else {
      XCTFail("Couldn't create HTTPURLResponse")
      return HTTPURLResponse()
    }

    return response
  }
}
