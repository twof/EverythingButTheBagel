import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore

struct CatFactsListView: View {
  let store: StoreOf<CatFactsListViewModelReducer>

  var body: some View {
    List {
      ForEach(store.facts) { fact in
        Text(fact.fact)
      }
    }.task {
      await store.send(.task).finish()
    }
  }
}

// Configurable preview
#Preview {
  CatFactsListView(
    store: Store(
      initialState: CatFactsListViewModelReducer.State(),
      reducer: {
        CatFactsListViewModelReducer()
      }
    )
  )
}

// Preview with live dependencies
#Preview {
  let store = Store(
    initialState: CatFactsListBase.State(
      viewModel: .init(),
      dataSource: CatFactsListDataSource.State()
    ),
    reducer: { CatFactsListBase() }
  )
  return CatFactsListView(
    store: store.scope(state: \.viewModel, action: \.viewModel)
  )
}
