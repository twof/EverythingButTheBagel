import Foundation

public protocol Caching {
  var key: String { get }
  func save<Value: Encodable>(_ value: Value)
  func load<Value: Decodable>() -> Value?
}

public final class DocumentsCache: Caching {
  public init(
    key: String,
    fileManager: FileManager = .default,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    self.key = key
    self.decoder = decoder
    self.encoder = encoder
    
    self.fileUrl = fileManager
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("\(key).json")
  }
  
  public let key: String
  let decoder: JSONDecoder
  let encoder: JSONEncoder
  let fileUrl: URL
  
  public func save<Value: Encodable>(_ value: Value) {
    let data = try? encoder.encode(value)
    try? data?.write(to: fileUrl)
  }
  
  public func load<Value: Decodable>() -> Value? {
    guard let data = try? Data(contentsOf: fileUrl) else { return nil }
    return try? decoder.decode(Value.self, from: data)
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
