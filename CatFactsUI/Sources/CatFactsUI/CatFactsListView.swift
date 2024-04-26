import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import ControllableScrollView
import Sprinkles
import Shimmer
import CatFactsCore

public struct CatFactsListView: View {
  let store: StoreOf<CatFactsListViewModelReducer>
  @State var scrollController = ScrollTrackerModel()

  public init(store: StoreOf<CatFactsListViewModelReducer>) {
    self.store = store
    self.scrollController = ScrollTrackerModel()
  }

  public var body: some View {
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

        if store.status == .loaded(data: []) {
          emptyListView(localizedText: store.state.emptyListMessage)
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

@ViewBuilder func emptyListView(localizedText: LocalizedTextState) -> some View {
  VStack(spacing: 15) {
    Image(systemName: "questionmark.circle.fill")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 50)
      .foregroundStyle(.red)

    LocalizedText(localizedText)
      .font(.title3)
      .multilineTextAlignment(.center)
  }
  .padding()
}

#Preview {
  emptyListView(localizedText: LocalizedTextState(text: "No facts here! Pull to refresh to check again."))
    .environment(\.locale, .init(identifier: "es"))
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
  )
  .preferredColorScheme(.dark)
  .environment(\.locale, .init(identifier: "es"))
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
