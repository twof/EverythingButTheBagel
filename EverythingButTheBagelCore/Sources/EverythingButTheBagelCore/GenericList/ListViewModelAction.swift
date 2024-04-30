public protocol ListViewModelAction<ResponseModel, ViewModel> {
  associatedtype ResponseModel
  associatedtype ViewModel: Identifiable

  static func newResponse(_: ResponseModel, strategy: NewResponseStrategy) -> Self
  static func delegate(_: ListViewModelDelegate<ViewModel.ID>) -> Self
  static func scroll(position: Double) -> Self
  static func isLoading(_: Bool) -> Self
}
