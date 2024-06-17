import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles
import CatFactsCore

@ViewBuilder
@MainActor
// swiftlint:disable:next identifier_name
public func CatFactsListView(store: StoreOf<CatFactsListViewModelReducer>) -> some View {
  GenericListView(store: store) { fact in
    CatFactListItem(vm: fact)
  }
}

// Configurable preview
#Preview {
  CatFactsListView(
    store: Store(
      initialState: CatFactsListViewModelReducer.State(),
      reducer: {
        CatFactsListViewModelReducer.catFacts
      }
    )
  )
  .preferredColorScheme(.dark)
  .environment(\.locale, .init(identifier: "es"))
}

// Preview with live dependencies
#Preview {
  let store = Store(
    initialState: CatFactsListBase.State(),
    reducer: { CatFactsListBase.catFacts }
  )
  return CatFactsListView(
    store: store.scope(state: \.viewModel, action: \.viewModel)
  )
}
