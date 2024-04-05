import SwiftUI
import EverythingButTheBagelCore
import ComposableArchitecture

@main
struct EverythingButTheBagelApp: App {
  let store: StoreOf<AppReducer>

  init() {
    self.store = Self.createStore()
    EverythingButTheBagelCore.appSetup()
  }
  var body: some Scene {
    WindowGroup {
      BaseAppScreen(store: store, view: {
        CatFactsListView(store: store.scope(state: \.catFacts.viewModel, action: \.catFacts.viewModel))
      })
    }
  }

  static func createStore() -> StoreOf<AppReducer> {
    let documentCache = DocumentsCache(key: "app-state")

    // Load from cache and write to it on every event
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
