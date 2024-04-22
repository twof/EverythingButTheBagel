import Foundation

public protocol ErrorReportingAction {
  static func error(_: EquatableError, sourceId: String, errorId: UUID) -> Self
}

public protocol ErrorReportingDelegate {
  associatedtype Delegate: ErrorReportingAction
  static func delegate(_: Delegate) -> Self
}
