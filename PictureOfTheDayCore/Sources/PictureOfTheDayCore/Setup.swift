import Dependencies
import SwiftDotenv
import Foundation
import ComposableArchitecture

public struct Setup: DependencyKey {
  public static let liveValue: @Sendable () throws -> Void = {
    guard let path = Bundle.module.path(forResource: "prod", ofType: "env") else {
      throw Dotenv.LoadingFailure.environmentFileIsMissing
    }
    try Dotenv.configure(atPath: path)
  }

  public static let testValue: @Sendable () throws -> Void = unimplemented("setup")
}

extension DependencyValues {
  var pictureOfTheDaySetup: @Sendable () throws -> Void {
    get { self[Setup.self] }
    set { self[Setup.self] = newValue }
  }
}

@DependencyClient
public struct APIKeys: Sendable {
  public var potd: @Sendable () -> String = { "" }
}

extension APIKeys: DependencyKey {
  public static let liveValue = APIKeys {
    @Dependency(\.pictureOfTheDaySetup) var setup

    do {
      try setup()
      return Dotenv["NASA_API_KEY"]!.stringValue
    } catch {
      fatalError()
    }
  }

  public static let testValue = APIKeys()
}

extension DependencyValues {
  var apiKeys: APIKeys {
    get { self[APIKeys.self] }
    set { self[APIKeys.self] = newValue }
  }
}
