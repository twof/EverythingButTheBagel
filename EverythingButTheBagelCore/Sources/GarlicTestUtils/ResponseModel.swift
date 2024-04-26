public struct ResponseModel: Codable, Equatable {
  public let fact: String

  public init(fact: String) {
    self.fact = fact
  }
}
