import Foundation
import ComposableArchitecture

@DependencyClient
public struct FileClient: Sendable {
  public var read: @Sendable (_ url: URL) throws -> Data
  public var write: @Sendable (_ url: URL, _ data: Data) throws -> Void
  public var exists: @Sendable (_ url: URL) -> Bool = { _ in true }
}

extension FileClient: DependencyKey {
  /// Performs an encrypted write to the provided `URL`
  public static let liveValue = FileClient { url in
    try Data(contentsOf: url)
  } write: { url, data in
    try data.write(to: url, options: [.completeFileProtection])
  } exists: { url in
    FileManager.default.fileExists(atPath: url.path())
  }

  public static let testValue = FileClient()
}

public extension DependencyValues {
  var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}
