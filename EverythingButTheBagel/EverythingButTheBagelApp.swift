import SwiftUI
import EverythingButTheBagelCore
import ComposableArchitecture
import AppCore
import PictureOfTheDayUI

@main
struct EverythingButTheBagelApp: App {
  let store: StoreOf<AppReducer>

  init() {
    self.store = Self.createStore()
    EverythingButTheBagelCore.appSetup()
  }

  var body: some Scene {
    WindowGroup {
      BaseAppScreen(store: store.scope(state: \.errors, action: \.errors), view: {
        PictureOfTheDayListView(
          elements: store.scope(state: \.potd, action: \.potd).listElements(),
          vm: store.scope(state: \.potd.viewModel, action: \.potd.viewModel)
        )
      })
    }
  }

  static func createStore() -> StoreOf<AppReducer> {
    let documentCache = DocumentsCache(key: "app-state")

    // Load from cache and write to it on every action
    return Store(
      initialState:
//        documentCache.load() ??
        AppReducer.State(),
      reducer: {
        AppReducer()
//          ._printChanges()
//          .caching(cache: documentCache)
      }
    )
  }
}
