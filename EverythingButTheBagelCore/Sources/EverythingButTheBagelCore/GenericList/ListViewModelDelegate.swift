/// The point of delegate actions is to alert parent reducers to some action.
public enum ListViewModelDelegate<RowId: Equatable>: Equatable {
  /// In this case, the parent is being alerted that the view did load.
  case task
  case nextPage
  case refresh
  case rowTapped(RowId)
}
