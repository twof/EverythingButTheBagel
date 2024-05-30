import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles
import PictureOfTheDayCore
import ControllableScrollView

public typealias POTDListElements = ListViewModelStatus<POTDItemStores>

public struct POTDItemStores: Identifiable, Equatable {
  public var id: String {
    cellContent.state.id
  }
  public let cellContent: StoreOf<PictureOfTheDayItemViewModel>
  public let asyncImage: StoreOf<AsyncImageViewModel>
}

public struct PictureOfTheDayListView: View {
  let elements: POTDListElements
  @Bindable var vm: StoreOf<POTDListAttemptVM>
  @State var scrollController = ScrollTrackerModel()
  private var destination: ((StoreOf<POTDPath>) -> AnyView?)?

  public init(elements: POTDListElements, vm: StoreOf<POTDListAttemptVM>) {
    self.elements = elements
    self.vm = vm
  }

  public var body: some View {
    NavigationStack(path: $vm.scope(state: \.path, action: \.path)) {
      ControllableScrollView(scrollModel: $scrollController) {
        LazyVStack(spacing: 0) {
          ForEach(elements.data) { stores in
            row(store: stores).id(stores.id)
          }

          ForEach(elements.placeholders) { _ in
            PictureOfTheDayListItem.loadingPlaceholder
          }

          if elements == .loaded(data: []) {
            emptyListView(localizedText: vm.state.emptyListMessage)
          }
        }
      }
      .task {
        // Scroll to set position on load
        self.scrollController.scroll(position: vm.scrollPosition)
        await vm.send(.delegate(.task)).finish()
      }
      .onChange(of: scrollController.position) { _, newValue in
        vm.send(.scroll(position: newValue))
      }
      .refreshable {
        vm.send(.delegate(.refresh))
      }
    } destination: { destination?($0) }
  }

  @ViewBuilder func row(store: POTDItemStores) -> some View {
    PictureOfTheDayListItem(stores: store)
      .onTapGesture {
        store.cellContent.send(.delegate(.didTap))
      }
      .onAppear {
        store.cellContent.send(.delegate(.didAppear))
      }
  }
}

// Live preview
#Preview {
  let store = Store(
    initialState: POTDListAttemptBase.State(
      elements: .loaded(
        data: [
          .init(title: "hello world", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
               ),
          .init(title: "hello", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
               )
        ]
      )
    ),
    reducer: { POTDListAttemptBase() }
  )

  return PictureOfTheDayListView(
    elements: store.scope(state: \.elements.data, action: \.element)
      .reduce(
        .loaded(data: [])
      ) { (result: POTDListElements, childStore) in
        let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
        let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)

        let data = result.data

        return .loaded(data: data + [POTDItemStores(cellContent: textViewModel, asyncImage: imageViewModel)])
      },
    vm: store.scope(state: \.viewModel, action: \.viewModel)
  )
}

// Configurable preview
#Preview {
  return PictureOfTheDayListView(
    elements: .loaded(data: [
      .init(title: "Hello world"),
      .init(title: "Hello")
    ]),
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
        initialState: AsyncImageViewModel.State(),
        reducer: { AsyncImageViewModel() }
      )
    )
  }
}

public extension Store where State == POTDListAttemptBase.State, Action == POTDListAttemptBase.Action {
  func listElements() -> POTDListElements {
    let stores = self.scope(state: \.elements.data, action: \.element).reduce(
      into: IdentifiedArrayOf(uniqueElements: [])
    ) { (result: inout IdentifiedArrayOf<POTDItemStores>, childStore) in
      let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
      let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)
      result[id: textViewModel.state.id] = POTDItemStores(cellContent: textViewModel, asyncImage: imageViewModel)
    }

    return .loaded(data: stores)
  }
}
