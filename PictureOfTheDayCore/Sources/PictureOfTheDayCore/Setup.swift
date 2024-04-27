import Dependencies
import SwiftDotenv
import Foundation
import ComposableArchitecture

public struct Setup: DependencyKey {
  public static var liveValue: () throws -> Void = {
    let path = URL(string: #file)!.deletingLastPathComponent().appending(path: "prod.env")
    try Dotenv.configure(atPath: path.absoluteString)
  }

  public static var testValue: () throws -> Void = unimplemented("setup")
}

extension DependencyValues {
  var pictureOfTheDaySetup: () throws -> Void {
    get { self[Setup.self] }
    set { self[Setup.self] = newValue }
  }
}

@DependencyClient
public struct APIKeys {
  public var potd: () -> String = { "" }
}

extension APIKeys: DependencyKey {
  public static var liveValue = APIKeys {
    @Dependency(\.pictureOfTheDaySetup) var setup
    try! setup()
    // TODO: Error handling
    return Dotenv["NASA_API_KEY"]!.stringValue
  }

  public static var testValue = APIKeys()
}

extension DependencyValues {
  var apiKeys: APIKeys {
    get { self[APIKeys.self] }
    set { self[APIKeys.self] = newValue }
  }
}
