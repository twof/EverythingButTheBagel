/// Conformance indicates a type produces an error tracked by `ErrorIndicatorViewModel` which requires a `sourceId`
protocol ErrorProducer {
  static var errorId: String { get }
}
