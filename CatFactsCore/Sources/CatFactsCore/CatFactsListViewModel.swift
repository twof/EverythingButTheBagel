import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

@Reducer
public struct CatFactsListViewModelReducer {
  @ObservableState
  public struct State: Equatable, Codable, ListViewModelState {
    public let emptyListMessage = LocalizedTextState(
      text: String(
        localized: "No facts here! Pull to refresh to check again.",
        bundle: .module,
        comment: "Message to let the user know that there are no list items, but not due to an error."
      ),
      stringCatalogLocation: .stringCatalog()
    )

    public var status: ListViewModelStatus<CatFactViewModel>
    public var scrollPosition: Double

    public var isLoading: Bool {
      switch status {
      case .loading: true
      case .loaded: false
      }
    }

    public init(
      status: ListViewModelStatus<CatFactViewModel> = .loaded(data: []),
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
    case newResponse(CatFactsResponseModel, strategy: NewResponseStrategy = .append)
    case scroll(position: Double)
    case isLoading(Bool)
  }

  @Dependency(\.locale) var locale

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .newResponse(response, strategy):
        let newVms = response.data.map(CatFactViewModel.init(model:)).toIdentifiedArray
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

public struct CatFactViewModel: Codable, Equatable, Identifiable {
  public var id: String { fact }
  public let fact: String

  public init(model: CatFactModel) {
    self.fact = model.fact
  }

  public init(fact: String) {
    self.fact = fact
  }
}

extension CatFactViewModel {
  public static let placeholders = (0..<20).map {
    CatFactViewModel(
      fact: "Example of a long fact Example of a long fact Example of a long fact"
      + "Example of a long fact Example of a long fact Example of a long fact Example of a long"
      + "fact Example of a long fact \($0)"
    )
  }
}

extension IdentifiedArrayOf<CatFactViewModel> {
  public static let placeholders = CatFactViewModel.placeholders.toIdentifiedArray
}
