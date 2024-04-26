import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

@Reducer
public struct PictureOfTheDayViewModelReducer {
  @ObservableState
  public struct State: Equatable, Codable, ListViewModelState {
    public let emptyListMessage = LocalizedTextState(
      text: String(
        localized: "No pictures here! Pull to refresh to check again.",
        bundle: .module,
        comment: "Message to let the user know that there are no list items, but not due to an error."
      ),
      stringCatalogLocation: .stringCatalog()
    )

    public var status: ListViewModelStatus<PictureOfTheDayViewModel>
    public var scrollPosition: Double

    public var isLoading: Bool {
      switch status {
      case .loading: true
      case .loaded: false
      }
    }

    public init(
      status: ListViewModelStatus<PictureOfTheDayViewModel> = .loaded(data: []),
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

  public enum Action: Equatable, ListViewModelAction {
    case delegate(ListViewModelDelegate)
    case newResponse([POTDResponseModel], strategy: NewResponseStrategy = .append)
    case scroll(position: Double)
    case isLoading(Bool)
  }

  @Dependency(\.locale) var locale

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newResponse(newResponse, strategy):
        let newVms = newResponse.map(PictureOfTheDayViewModel.init(model:)).toIdentifiedArray
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
