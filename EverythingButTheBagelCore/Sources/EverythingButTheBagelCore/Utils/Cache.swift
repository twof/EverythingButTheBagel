import ComposableArchitecture
import Foundation
import Dependencies

public protocol Caching {
  var key: String { get }
  func save<Value: Encodable>(_ value: Value)
  func load<Value: Decodable>() -> Value?
}

public final class DocumentsCache: Caching, LoggingContext {
  public let loggingCategory: String = "Cache"

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
      cache.save(newState)

      return .merge(
        effect
      )
    }
  }
}
