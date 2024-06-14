// TODO: Conform this to Codable
// TODO: Special case when Value is optional treating none and some as not equal
@propertyWrapper
struct EquatableNoop<Value> {
  var wrappedValue: Value
}

extension EquatableNoop: Equatable {
  static func == (left: EquatableNoop<Value>, right: EquatableNoop<Value>) -> Bool {
    true
  }
}
