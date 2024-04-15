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
      BaseAppScreen(store: store, view: {
        CatFactsListView(store: store.scope(state: \.catFacts.viewModel, action: \.catFacts.viewModel))
      })
    }
  }

  static func createStore() -> StoreOf<AppReducer> {
    let documentCache = DocumentsCache(key: "app-state")

    // Load from cache and write to it on every action
    return Store(
      initialState:
        documentCache.load() ??
        AppReducer.State(),
      reducer: {
        AppReducer().caching(cache: documentCache)
      }
    )
  }
}
