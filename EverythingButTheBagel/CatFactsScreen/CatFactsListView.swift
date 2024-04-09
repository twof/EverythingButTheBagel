import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import ControllableScrollView
import Sprinkles
import Shimmer

struct CatFactsListView: View {
  let store: StoreOf<CatFactsListViewModelReducer>
  @State var scrollController = ScrollTrackerModel()

  init(store: StoreOf<CatFactsListViewModelReducer>) {
    self.store = store
    self.scrollController = ScrollTrackerModel()
  }

  var body: some View {
    ControllableScrollView(scrollModel: $scrollController) {
      LazyVStack(spacing: 0) {
        ForEach(store.status.data) { fact in
          CatFactListItem(vm: fact)
            .if(fact == store.status.loadingElement) { view in
              view.onAppear {
                store.send(.delegate(.nextPage))
              }
            }
        }

        ForEach(store.status.placeholders) { fact in
          CatFactListItem(vm: fact)
        }
        .if(store.isLoading) { view in
          view
            .redacted(reason: .placeholder)
            .shimmering()
        }

        if store.status.data.isEmpty, !store.isLoading {
          emptyListView()
        }
      }
    }
    .scrollDisabled(store.isLoading)
    .task {
      // Scroll to set position on load
      self.scrollController.scroll(position: store.scrollPosition)
      await store.send(.delegate(.task)).finish()
    }
    .onChange(of: scrollController.position) { _, newValue in
      store.send(.scroll(position: newValue))
    }
    .overlay {
      if store.isLoading {
        ProgressView()
      }
    }
    .refreshable {
      store.send(.delegate(.refresh))
    }
  }
}

@ViewBuilder func emptyListView() -> some View {
  VStack(spacing: 15) {
    Image(systemName: "questionmark.circle.fill")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 50)
      .foregroundStyle(.red)

    Text("No facts here! Pull to refresh to check again.")
      .font(.title3)
      .multilineTextAlignment(.center)
  }
  .padding()
}

#Preview {
  emptyListView()
}

// Configurable preview
#Preview {
  CatFactsListView(
    store: Store(
      initialState: CatFactsListViewModelReducer.State(status: .loaded(data: [])),
      reducer: {
        CatFactsListViewModelReducer()
      }
    )
  ).preferredColorScheme(.dark)
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
