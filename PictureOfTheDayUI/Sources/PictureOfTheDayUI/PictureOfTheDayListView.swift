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

extension POTDItemStores {
  public static func loadingMock(id: String) -> POTDItemStores {
    POTDItemStores(
      cellContent: .init(
        initialState: PictureOfTheDayItemViewModel.State(title: "title \(id)"),
        reducer: { PictureOfTheDayItemViewModel() }
      ),
      asyncImage: .init(
        initialState: AsyncImageViewModel.State(imageName: "", isLoading: true),
        reducer: { AsyncImageViewModel() }
      )
    )
  }
}

public struct PictureOfTheDayListView: View {
  let elements: POTDListElements
  @Bindable var vm: StoreOf<POTDListAttemptVM>
//  @State var scrollController = ScrollTrackerModel()

  public init(elements: POTDListElements, vm: StoreOf<POTDListAttemptVM>) {
    self.elements = elements
    self.vm = vm
  }

  public var body: some View {
    NavigationStack(path: $vm.scope(state: \.path, action: \.path)) {
      ScrollView {
//      ControllableScrollView(scrollModel: $scrollController) {
        POTDForEach(elements: elements)

        if elements.isEmpty {
          emptyListView(localizedText: vm.state.emptyListMessage)
        }
        //      }
      }
      .task {
        // Scroll to set position on load
//        self.scrollController.scroll(position: vm.scrollPosition)
        await vm.send(.delegate(.task)).finish()
      }
//      .onChange(of: scrollController.position) { _, newValue in
//        vm.send(.scroll(position: newValue))
//      }
      .refreshable {
        vm.send(.delegate(.refresh))
      }
    } destination: { path in
      switch path.case {
      case let .detail(store):
        POTDDetailView(
          store: store.scope(state: \.viewModel, action: \.viewModel),
          imageStore: store.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)
        )
      }
    }
  }
}

struct POTDForEach: View {
  let elements: POTDListElements

  var body: some View {
    LazyVStack(spacing: 0) {
      ForEach(elements.data) { stores in
        POTDForEachRow(store: stores)
      }

      // Put one loading placeholder at the bottom of the list to indicate loading
      // for infinite scrolling
      PictureOfTheDayListItem.loadingPlaceholder

      ForEach(elements.placeholders) { _ in
        PictureOfTheDayListItem.loadingPlaceholder
      }
    }
  }
}

struct POTDForEachRow: View {
  let store: POTDItemStores

  var body: some View {
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
      elements: ListViewModelStatus(data: [
        .init(
          title: "hello world",
          asyncImage: .init(
            imageUrl: URL(
              string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg"
            )!,
            imageName: "Ryugu01_Rover1aHayabusa2_960.jpg"
          )
        ),
        .init(
          title: "hello",
          asyncImage: .init(
            imageUrl: URL(
              string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg"
            )!,
            imageName: "Ryugu01_Rover1aHayabusa2_960.jpg"
          )
        )
      ])
    ),
    reducer: { POTDListAttemptBase() }
  )

  PictureOfTheDayListView(
    elements: store.scope(state: \.elements.data, action: \.element)
      .reduce(
        POTDListElements()
      ) { (result: POTDListElements, childStore) in
        let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
        let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)

        let data = result.data

        return .init(data: data + [POTDItemStores(cellContent: textViewModel, asyncImage: imageViewModel)])
      },
    vm: store.scope(state: \.viewModel, action: \.viewModel)
  )
}

// Configurable preview
#Preview {
  return PictureOfTheDayListView(
    elements: POTDListElements(data: [
      .init(title: "Hello world"),
      .init(title: "Hello world")
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
        initialState: AsyncImageViewModel.State(imageName: "", isLoading: false),
        reducer: { AsyncImageViewModel() }
      )
    )
  }
}

public extension StoreOf<POTDListAttemptBase> {
  func listElements() -> POTDListElements {
    // This uses a computed property for scoping and may cause performance issues later
    // swiftlint:disable:next line_length
    // https://github.com/pointfreeco/swift-composable-architecture/blob/main/Sources/ComposableArchitecture/Documentation.docc/Articles/Performance.md#store-scoping
    let stores = self.scope(state: \.elements.data, action: \.element).reduce(
      into: IdentifiedArrayOf(uniqueElements: [])
    ) { (result: inout IdentifiedArrayOf<POTDItemStores>, childStore) in
      let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
      let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)
      result[id: textViewModel.state.id] = POTDItemStores(
        cellContent: textViewModel,
        asyncImage: imageViewModel
      )
    }

    let placeholderStores = self.scope(state: \.elements.placeholders, action: \.element).reduce(
      into: IdentifiedArrayOf(uniqueElements: [])
    ) { (result: inout IdentifiedArrayOf<POTDItemStores>, childStore) in
      let textViewModel = childStore.scope(state: \.viewModel, action: \.viewModel)
      let imageViewModel = childStore.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel)
      result[id: textViewModel.state.id] = POTDItemStores(
        cellContent: textViewModel,
        asyncImage: imageViewModel
      )
    }

    return .init(data: stores, placeholders: placeholderStores, isLoading: self.elements.isLoading)

  }
}
