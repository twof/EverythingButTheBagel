import SwiftUI
import EverythingButTheBagelCore
import ComposableArchitecture
import AppCore
import CatFactsUI
import PictureOfTheDayUI
import PictureOfTheDayCore

@main
struct EverythingButTheBagelApp: App {
//  let store: StoreOf<PictureOfTheDayItemBase>
  let store: StoreOf<AppReducer>

  init() {
    self.store = Self.createStore()
    EverythingButTheBagelCore.appSetup()
  }

  var body: some Scene {
    WindowGroup {
//      Image(systemName: "questionmark.circle.fill")
//      CatFactsListView(
//        store: Store(
//          initialState: CatFactsListViewModelReducer.State(status: .loaded(data: [])),
//          reducer: {
//            CatFactsListViewModelReducer()
//          }
//        )
//      )
//      .preferredColorScheme(.dark)
//      .environment(\.locale, .init(identifier: "es"))
//      Text("Hello")
//        .withError(vm: .init(id: "0", message: "Oh no! Something went wrong"))

//      PictureOfTheDayListItem(
//        store: store.scope(state: \.viewModel, action: \.viewModel)
//      )

//      POTDDetailView(
//        store: store.scope(state: \.viewModel, action: \.viewModel),
//        imageStore: store
//          .scope(state: \.asyncImage, action: \.asyncImage)
//          .scope(state: \.viewModel, action: \.viewModel)
//      )

      BaseAppScreen(store: store.scope(state: \.errors, action: \.errors), view: {
        PictureOfTheDayListView(
          elements: store.scope(state: \.potd, action: \.potd).listElements(),
          vm: store.scope(state: \.potd.viewModel, action: \.potd.viewModel)
        )
//        CatFactsListView(store: store.scope(state: \.catFacts.viewModel, action: \.catFacts.viewModel))
      })
    }
  }

  static func createStore() -> StoreOf<AppReducer> {
//    let store = Store(
//      initialState: PictureOfTheDayItemBase.State(
//        title: "Hey this is an image",
//        asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
//      ),
//      reducer: {
//        PictureOfTheDayItemBase()
//      }
//    )
//
//    return store
    let documentCache = DocumentsCache(key: "app-state")
//
//    let base = Store(
//      initialState: PictureOfTheDayDetailBase.State(
//        asyncImage: AsyncImageBase.State(
//          imageUrl: URL(
//            string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg"
//          )!
//        ),
//        viewModel: PictureOfTheDayDetailVM.State(
//          title: "Hello world",
//          description: "A long description"
//        )
//      )) {
//        PictureOfTheDayDetailBase()
//      }
//
//    return base

    // Load from cache and write to it on every action
    return Store(
      initialState:
//        documentCache.load() ??
        AppReducer.State(),
      reducer: {
        AppReducer().caching(cache: documentCache)
      }
    )
  }
}
