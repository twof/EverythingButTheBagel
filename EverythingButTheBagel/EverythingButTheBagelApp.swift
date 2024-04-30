import SwiftUI
import EverythingButTheBagelCore
import ComposableArchitecture
import AppCore
import CatFactsUI
import PictureOfTheDayUI
import PictureOfTheDayCore

@main
struct EverythingButTheBagelApp: App {
  let store: StoreOf<PictureOfTheDayDetailBase>

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

      POTDDetailView(
        store: store.scope(state: \.viewModel, action: \.viewModel),
        imageStore: store
          .scope(state: \.asyncImage, action: \.asyncImage)
          .scope(state: \.viewModel, action: \.viewModel)
      )

//      BaseAppScreen(store: store.scope(state: \.errors, action: \.errors), view: {
//        CatFactsListView(store: store.scope(state: \.catFacts.viewModel, action: \.catFacts.viewModel))
//      })
    }
  }

  static func createStore() -> StoreOf<PictureOfTheDayDetailBase> {
    let documentCache = DocumentsCache(key: "app-state")

    let base = Store(
      initialState: PictureOfTheDayDetailBase.State(
        asyncImage: AsyncImageBase.State(
          imageUrl: URL(
            string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg"
          )!
        ),
        viewModel: PictureOfTheDayDetailVM.State(
          title: "Hello world",
          description: "A long description"
        )
      )) {
        PictureOfTheDayDetailBase()
      }

    return base

    // Load from cache and write to it on every action
//    return Store(
//      initialState:
//        documentCache.load() ??
//        AppReducer.State(),
//      reducer: {
//        AppReducer().caching(cache: documentCache)
//      }
//    )
  }
}
