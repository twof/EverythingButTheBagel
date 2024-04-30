import IdentifiedCollections

public enum ListViewModelStatus<ViewModel: Identifiable & Codable & Equatable>: Codable, Equatable {
  case loading(data: IdentifiedArrayOf<ViewModel>, placeholders: IdentifiedArrayOf<ViewModel>)
  case loaded(data: IdentifiedArrayOf<ViewModel>)
}

extension ListViewModelStatus {
  public var data: IdentifiedArrayOf<ViewModel> {
    switch self {
    case let .loaded(data): data
    case let .loading(data, _): data
    }
  }

  public var placeholders: IdentifiedArrayOf<ViewModel> {
    switch self {
    case .loaded: []
    case let .loading(_, placeholders): placeholders
        .prefix(max(1, 7 - data.count))
        .toIdentifiedArray
    }
  }

  /// When this element comes on screen, start loading the next page
  /// Returns nil when there are no elements in `data` and the first element when there are fewer than 3
  public var loadingElement: ViewModel? {
    self.data[back: 2]
  }
}
