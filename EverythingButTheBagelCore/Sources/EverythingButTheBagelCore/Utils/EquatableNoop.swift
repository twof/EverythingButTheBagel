// TODO: Conform this to Codable
// TODO: Special case when Value is optional treating none and some as not equal
@propertyWrapper
struct EquatableNoop<Value> {
  var wrappedValue: Value
}

extension EquatableNoop: Equatable {
  static func == (lhs: EquatableNoop<Value>, rhs: EquatableNoop<Value>) -> Bool {
    true
  }
}
