import Dependencies
import SwiftDotenv
import Foundation
import ComposableArchitecture

public struct Setup: DependencyKey {
  public static var liveValue: () throws -> Void = {
    guard let path = Bundle.module.path(forResource: "prod", ofType: "env") else {
      throw Dotenv.LoadingFailure.environmentFileIsMissing
    }
    try Dotenv.configure(atPath: path)
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

    do {
      try setup()
      return Dotenv["NASA_API_KEY"]!.stringValue
    } catch {
      fatalError()
    }
  }

  public static var testValue = APIKeys()
}

extension DependencyValues {
  var apiKeys: APIKeys {
    get { self[APIKeys.self] }
    set { self[APIKeys.self] = newValue }
  }
}
