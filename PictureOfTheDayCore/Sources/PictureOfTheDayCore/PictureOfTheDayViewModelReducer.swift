import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayViewModelReducer {
  @ObservableState
  public struct State: Equatable, Codable {
    public let emptyListMessage = LocalizedTextState(
      text: String(
        localized: "No pictures here! Pull to refresh to check again.",
        bundle: .module,
        comment: "Message to let the user know that there are no list items, but not due to an error."
      ),
      stringCatalogLocation: .stringCatalog()
    )

    public var status: Status
    public var scrollPosition: Double

    public var isLoading: Bool {
      switch status {
      case .loading: true
      case .loaded: false
      }
    }

    public init(
      status: Status = .loaded(data: []),
      scrollPosition: Double = 0.0
    ) {
      self.scrollPosition = scrollPosition
      self.status = status
    }

    enum CodingKeys: CodingKey {
      // swiftlint:disable:next identifier_name
      case _status
      // swiftlint:disable:next identifier_name
      case _scrollPosition
    }
  }

  public enum Action: Equatable {
    // The point of delegate actions is to alert parent reducers to some action.
    // swiftlint:disable:next nesting
    public enum Delegate: Equatable {
      // In this case, the parent is being alerted that the view did load.
      case task
      case nextPage
      case refresh
    }

    // swiftlint:disable:next nesting
    public enum NewElementsStrategy: Equatable {
      case reset
      case append
    }

    case delegate(Delegate)
    case newElements([POTDResponseModel], strategy: NewElementsStrategy = .append)
    case scroll(position: Double)
    case isLoading(Bool)
  }

  @Dependency(\.locale) var locale

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newElements(newElements, strategy):
        let newVms = newElements.map(PictureOfTheDayViewModel.init(model:)).toIdentifiedArray
        switch strategy {
        case .append:
          state.status = .loaded(data: state.status.data + newVms)
        case .reset:
          state.status = .loaded(data: newVms)
        }

        return .none

      case let .scroll(position):
        state.scrollPosition = position
        return .none

      case let .isLoading(isLoading):
        let data = state.status.data

        state.status = isLoading
        ? .loading(data: data, placeholders: .placeholders)
        : .loaded(data: data)
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public enum Status: Codable, Equatable {
  case loading(data: IdentifiedArrayOf<PictureOfTheDayViewModel>, placeholders: IdentifiedArrayOf<PictureOfTheDayViewModel>)
  case loaded(data: IdentifiedArrayOf<PictureOfTheDayViewModel>)
}

extension Status {
  public var data: IdentifiedArrayOf<PictureOfTheDayViewModel> {
    switch self {
    case let .loaded(data): data
    case let .loading(data, _): data
    }
  }

  public var placeholders: IdentifiedArrayOf<PictureOfTheDayViewModel> {
    switch self {
    case .loaded: []
    case let .loading(_, placeholders): placeholders
        .prefix(max(1, 7 - data.count))
        .toIdentifiedArray
    }
  }

  /// When this element comes on screen, start loading the next page
  /// Returns nil when there are no elements in `data` and the first element when there are fewer than 3
  public var loadingElement: PictureOfTheDayViewModel? {
    self.data[back: 2]
  }
}

public struct PictureOfTheDayViewModel: Codable, Equatable, Identifiable {
  public var id: String { title }
  public let title: String

  public init(model: POTDResponseModel) {
    self.title = model.title
  }

  public init(title: String) {
    self.title = title
  }
}

extension PictureOfTheDayViewModel {
  public static let placeholders = (0..<20).map {
    PictureOfTheDayViewModel(
      title: "Example of a long fact Example of a long fact Example of a long fact"
      + "Example of a long fact Example of a long fact Example of a long fact Example of a long"
      + "fact Example of a long fact \($0)"
    )
  }
}

extension IdentifiedArrayOf<PictureOfTheDayViewModel> {
  public static let placeholders = PictureOfTheDayViewModel.placeholders.toIdentifiedArray
}