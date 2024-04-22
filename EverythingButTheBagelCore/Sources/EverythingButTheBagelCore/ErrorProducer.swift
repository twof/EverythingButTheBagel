/// Conformance indicates a type produces an error tracked by `ErrorIndicatorViewModel` which requires a `sourceId`
protocol ErrorProducer {
  var errorSourceId: String { get }
}
