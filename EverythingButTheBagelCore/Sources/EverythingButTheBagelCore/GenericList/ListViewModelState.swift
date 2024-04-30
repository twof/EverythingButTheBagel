public protocol ListViewModelState {
  associatedtype ViewModel: Codable & Equatable & Identifiable
  var status: ListViewModelStatus<ViewModel> { get set }
  var scrollPosition: Double { get set }
}
