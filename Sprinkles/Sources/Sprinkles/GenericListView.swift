import SwiftUI
import Shimmer
import EverythingButTheBagelCore
import ComposableArchitecture
import ControllableScrollView

// swiftlint:disable opening_brace
public struct GenericListView<
  ViewModel: Codable & Equatable & Identifiable & ViewModelPlaceholders,
  PathReducer: CaseReducer,
  Content: View
>: View where
  PathReducer.Action: Equatable,
  PathReducer.State: Equatable & Codable & CaseReducerState & ObservableState,
  PathReducer.State.StateReducer.Action == PathReducer.Action
{
  public typealias ViewModelReducer = ListFeatureViewModelReducer<ViewModel, PathReducer>
  @Bindable var store: StoreOf<ViewModelReducer>
  @State var scrollController = ScrollTrackerModel()
  let content: (ViewModel) -> Content
  private var destination: ((StoreOf<PathReducer>) -> AnyView?)?

  public init(store: StoreOf<ViewModelReducer>, @ViewBuilder content: @escaping (ViewModel) -> Content) {
    self.store = store
    self.scrollController = ScrollTrackerModel()
    self.content = content
  }

  public func destination<Destination: View>(_ closure: @escaping (StoreOf<PathReducer>) -> Destination?) -> Self {
    var copy = self
    copy.destination = { AnyView(closure($0)) }
    return copy
  }

  public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      ControllableScrollView(scrollModel: $scrollController) {
        LazyVStack(spacing: 0) {
          ForEach(store.status.data) { viewModel in
            row(viewModel: viewModel)
          }

          ForEach(store.status.placeholders) { viewModel in
            content(viewModel)
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
    } destination: { destination?($0) }
  }

  @ViewBuilder func row(viewModel: ViewModel) -> some View {
    content(viewModel)
      .onTapGesture {
        store.send(.delegate(.rowTapped(viewModel.id)))
      }
      .if(viewModel == store.status.loadingElement) { view in
        view.onAppear {
          store.send(.delegate(.nextPage))
        }
      }
  }
}
