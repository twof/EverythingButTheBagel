import IdentifiedCollections

public enum ListViewModelStatus<ViewModel: Identifiable> {
  case loading(data: IdentifiedArrayOf<ViewModel>, placeholders: IdentifiedArrayOf<ViewModel>)
  case loaded(data: IdentifiedArrayOf<ViewModel>)
}

extension ListViewModelStatus {
  public var data: IdentifiedArrayOf<ViewModel> {
    get {
      switch self {
      case let .loaded(data): data
      case let .loading(data, _): data
      }
    }

    set {
      switch self {
      case .loaded:
        self = .loaded(data: newValue)
      case let .loading(_, placeholders):
        self = .loading(data: newValue, placeholders: placeholders)
      }
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

extension ListViewModelStatus {
  public func appending(_ newData: ViewModel) -> Self {
    switch self {
    case let .loaded(data):
      return .loaded(data: data + [newData])
    case let .loading(data, _):
      return .loading(data: data + [newData], placeholders: placeholders)
    }
  }

  public func appending(contentsOf newData: [ViewModel]) -> Self {
    switch self {
    case let .loaded(data):
      return .loaded(data: data + newData)
    case let .loading(data, _):
      return .loading(data: data + newData, placeholders: placeholders)
    }
  }
}

extension ListViewModelStatus: Codable where ViewModel: Codable { }

extension ListViewModelStatus: Equatable where ViewModel: Equatable { }
