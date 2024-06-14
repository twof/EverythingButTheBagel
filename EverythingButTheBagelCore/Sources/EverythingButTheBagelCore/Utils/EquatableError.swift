/// Wrapper around standard library errors because by default they aren't equatable.
///
/// The lack of equatability makes testing very difficult.
/// Credit: https://sideeffect.io/posts/2021-12-10-equatableerror/
public struct EquatableError: Error, Equatable, CustomStringConvertible {
  let base: Error
  private let equals: (Error) -> Bool

  init<Base: Error>(_ base: Base) {
    self.base = base
    self.equals = { String(reflecting: $0) == String(reflecting: base) }
  }

  init<Base: Error & Equatable>(_ base: Base) {
    self.base = base
    self.equals = { ($0 as? Base) == base }
  }

  public static func == (left: EquatableError, right: EquatableError) -> Bool {
    left.equals(right.base)
  }

  public var description: String {
    "\(self.base)"
  }

  func asError<Base: Error>(type: Base.Type) -> Base? {
    self.base as? Base
  }

  var localizedDescription: String {
    self.base.localizedDescription
  }
}

extension Error {
  public func toEquatableError() -> EquatableError {
    // Avoid re-wrapping EquatableErrors
    if let error = self as? EquatableError {
      return error
    }

    return EquatableError(self)
  }
}
