import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import ControllableScrollView

struct CatFactsListView: View {
  let store: StoreOf<CatFactsListViewModelReducer>
  @State var scrollController = ScrollTrackerModel()

  var body: some View {
    ControllableScrollView(scrollModel: $scrollController) {
      LazyVStack {
        ForEach(store.facts) { fact in
          Text(fact.fact)
        }
      }
    }
    .task {
      await store.send(.delegate(.task)).finish()
    }
    .onChange(of: scrollController.position) { _, newValue in
      store.send(.scroll(position: newValue))
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
    initialState: CatFactsListBase.State(),
    reducer: { CatFactsListBase() }
  )
  return CatFactsListView(
    store: store.scope(state: \.viewModel, action: \.viewModel)
  )
}
