import ComposableArchitecture
import Foundation
import Dependencies

public protocol Caching {
  var key: String { get }
  func save<Value: Encodable>(_ value: Value)
  func load<Value: Decodable>() -> Value?
}

public final class DocumentsCache: Caching, LoggingContext {
  let loggingCategory: String = "Cache"

  public init(
    key: String,
    fileManager: FileManager = .default,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    self.key = key
    self.decoder = decoder
    self.encoder = encoder

    // Using the `cachesDirectory` which hides the cache file from the user and allows the
    // OS to clear the cache if it needs to free up space
    self.fileUrl = fileManager
      .urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("\(key).json")
  }

  public let key: String
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder
  let fileUrl: URL

  @Dependency(\.fileClient) var fileClient

  public func save<Value: Encodable>(_ value: Value) {
    try? logErrors {
      let data = try encoder.encode(value)
      try fileClient.write(fileUrl, data)
    }
  }

  public func load<Value: Decodable>() -> Value? {
    try? logErrors {
      let data = try fileClient.read(fileUrl)
      return try decoder.decode(Value.self, from: data)
    }
  }
}

public extension Reducer where State: Codable {
  func caching(cache: Caching) -> Reduce<Self.State, Self.Action> {
    return Reduce<Self.State, Self.Action> { state, action in
      let effect = self.reduce(into: &state, action: action)
      let newState = state
      return .merge(
        .run(operation: { _ in
          cache.save(newState)
        }),
        effect
      )
    }
  }
}

@DependencyClient
struct FileClient {
  let read: (_ url: URL) throws -> Data
  let write: (_ url: URL, _ data: Data) throws -> Void
}

extension FileClient: DependencyKey {
  /// Performs an encrypted write to the provided `URL`
  static var liveValue = FileClient { url in
    try Data(contentsOf: url)
  } write: { url, data in
    try data.write(to: url, options: [.completeFileProtection])
  }

  static var testValue = FileClient(
    read: unimplemented("FileClient read"),
    write: unimplemented("FileClient write")
  )
}

extension DependencyValues {
  var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}
