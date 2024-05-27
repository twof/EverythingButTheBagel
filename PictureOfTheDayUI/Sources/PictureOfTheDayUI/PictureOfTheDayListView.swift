import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles
import PictureOfTheDayCore

public typealias POTDListElements = IdentifiedArrayOf<POTDItemStores>

public struct POTDItemStores: Identifiable {
  public var id: String {
    cellContent.state.id
  }
  public let cellContent: StoreOf<PictureOfTheDayItemViewModel>
  public let asyncImage: StoreOf<AsyncImageViewModel>
}

public struct PictureOfTheDayListView: View {
  let elements: POTDListElements
  let vm: StoreOf<POTDListAttemptVM>

  public init(elements: POTDListElements, vm: StoreOf<POTDListAttemptVM>) {
    self.elements = elements
    self.vm = vm
  }

  public var body: some View {
    List(elements) { store in
      PictureOfTheDayListItem(stores: store)
    }.task {
      await vm.send(.delegate(.task)).finish()
    }
  }
}

// Live preview
#Preview {
  let store = Store(
    initialState: POTDListAttemptBase.State(elements: [
      .init(title: "hello world", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
           ),
      .init(title: "hello", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
           )
    ]),
    reducer: { POTDListAttemptBase() }
  )

  return PictureOfTheDayListView(
    elements: store.scope(state: \.elements, action: \.element)
      .reduce(
        into: POTDListElements(uniqueElements: [])
      ) { (result: inout POTDListElements, childStore) in
        let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
        let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)
        result[id: textViewModel.state.id] = POTDItemStores(cellContent: textViewModel, asyncImage: imageViewModel)
      },
    vm: store.scope(state: \.viewModel, action: \.viewModel)
  )
}

// Configurable preview
#Preview {
  return PictureOfTheDayListView(
    elements: [
      .init(title: "Hello world"),
      .init(title: "Hello")
    ],
    vm: Store(initialState: POTDListAttemptVM.State(), reducer: { POTDListAttemptVM() })
  )
  .preferredColorScheme(.dark)
  .environment(\.locale, .init(identifier: "es"))
}

public extension POTDItemStores {
  init(title: String) {
    self.init(
      cellContent: .init(
        initialState: PictureOfTheDayItemViewModel.State(title: title),
        reducer: { PictureOfTheDayItemViewModel() }
      ),
      asyncImage: .init(
        initialState: AsyncImageViewModel.State(isLoading: true),
        reducer: { AsyncImageViewModel() }
      )
    )
  }
}

public extension Store where State == POTDListAttemptBase.State, Action == POTDListAttemptBase.Action {
  func listElements() -> POTDListElements {
    self.scope(state: \.elements, action: \.element).reduce(
      into: POTDListElements(uniqueElements: [])
    ) { (result: inout POTDListElements, childStore) in
      let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
      let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)
      result[id: textViewModel.state.id] = POTDItemStores(cellContent: textViewModel, asyncImage: imageViewModel)
    }
  }
}
