import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles
import PictureOfTheDayCore

public struct POTDItemStores: Identifiable {
  public var id: String {
    cellContent.state.id
  }
  public let cellContent: StoreOf<PictureOfTheDayItemViewModel>
  public let asyncImage: StoreOf<AsyncImageViewModel>
}

public struct PictureOfTheDayListView: View {
  let elements: IdentifiedArrayOf<POTDItemStores>

  public var body: some View {
    List(elements) { store in
      PictureOfTheDayListItem(text: PictureOfTheDayText(store: store.cellContent), image: AsyncImageLoader(store: store.asyncImage))
    }
  }
}

typealias ListElements = IdentifiedArrayOf<POTDItemStores>

func produceStores() -> ListElements {
  let store = Store(
    initialState: POTDListAttemptBase.State(elements: [
      .init(title: "hello world", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
           ),
      .init(title: "hello", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
           )
    ]),
    reducer: { POTDListAttemptBase() }
  )

  return store.scope(state: \.elements, action: \.element)
    .reduce(
      into: ListElements(uniqueElements: [])
    ) { (result: inout ListElements, childStore) in
      let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
      let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)
      result[id: textViewModel.state.id] = POTDItemStores(cellContent: textViewModel, asyncImage: imageViewModel)
    }
}

// Live preview
#Preview {
  return PictureOfTheDayListView(
    elements: produceStores()
  )
//  .preferredColorScheme(.dark)
//  .environment(\.locale, .init(identifier: "es"))
}

// Configurable preview
#Preview {
  return PictureOfTheDayListView(
    elements: [
      .init(
        cellContent: .init(
          initialState: PictureOfTheDayItemViewModel.State(title: "Hello World"),
          reducer: { PictureOfTheDayItemViewModel() }
        ),
        asyncImage: .init(
          initialState: AsyncImageViewModel.State(isLoading: true),
          reducer: { AsyncImageViewModel() }
        )
      ),
      .init(
        cellContent: .init(
          initialState: PictureOfTheDayItemViewModel.State(title: "Hello"),
          reducer: { PictureOfTheDayItemViewModel() }
        ),
        asyncImage: .init(
          initialState: AsyncImageViewModel.State(isLoading: true),
          reducer: { AsyncImageViewModel() }
        )
      )
    ]
  )
}
