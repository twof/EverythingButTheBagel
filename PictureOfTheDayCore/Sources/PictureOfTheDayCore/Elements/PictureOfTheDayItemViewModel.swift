import EverythingButTheBagelCore
import Foundation
import IdentifiedCollections
import ComposableArchitecture

@Reducer
public struct PictureOfTheDayItemViewModel {
  @ObservableState
  public struct State: Codable, Equatable, Identifiable {
    public var id: String { title }
    public let title: String
//    @Shared public var asyncImage: AsyncImageViewModel.State

    public init(
      title: String
//      ,
//      asyncImage: Shared<AsyncImageViewModel.State>
    ) {
      self.title = title
//      self._asyncImage = asyncImage
    }
  }

  public enum Action: Equatable {
//    case asyncImage(AsyncImageViewModel.Action)
  }

//  @Shared var asyncImageScope: Scope<State, Action, AsyncImageBase>

  public init(
//    asyncImageScope: Shared<Scope<State, Action, AsyncImageBase>>
  ) {
//    self._asyncImageScope = asyncImageScope
  }

  public var body: some ReducerOf<Self> {
//    asyncImageScope
    Reduce { state, action in
      let state = state
      let action = action
      return .none
    }
  }
}
