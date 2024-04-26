import SwiftUI
import Shimmer
import EverythingButTheBagelCore
import ComposableArchitecture
import ControllableScrollView

public struct GenericListView<
  ViewModel: Codable & Equatable & Identifiable & ViewModelPlaceholders,
  ResponseType: Codable & Equatable,
  Content: View
>: View {
  public typealias ViewModelReducer = ListFeatureViewModelReducer<ViewModel, ResponseType>
  let store: StoreOf<ViewModelReducer>
  @State var scrollController = ScrollTrackerModel()
  let content: (ViewModel) -> Content

  public init(store: StoreOf<ViewModelReducer>, @ViewBuilder content: @escaping (ViewModel) -> Content) {
    self.store = store
    self.scrollController = ScrollTrackerModel()
    self.content = content
  }

  public var body: some View {
    ControllableScrollView(scrollModel: $scrollController) {
      LazyVStack(spacing: 0) {
        ForEach(store.status.data) { vm in
          content(vm)
            .if(vm == store.status.loadingElement) { view in
              view.onAppear {
                store.send(.delegate(.nextPage))
              }
            }
        }

        ForEach(store.status.placeholders) { vm in
          content(vm)
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
