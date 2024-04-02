import SwiftUI
import EverythingButTheBagelCore
import ComposableArchitecture

/// Containter view that holds content, but displayes global information like errors
/// and connection status
struct BaseAppScreen<InnerView: View>: View {
  @Bindable var store: StoreOf<AppReducer>
  @ViewBuilder var view: () -> InnerView

  public init(
    store: StoreOf<AppReducer>,
    @ViewBuilder view: @escaping () -> InnerView
  ) {
    self.store = store
    self.view = view
  }

  var body: some View {
    view()
      .withError(vm: store.errors.error())
  }
}

// Live preview. Hits network.
#Preview {
  let store = Store(
    initialState: AppReducer.State(errors: .init(errors: ["anything": [.init(id: "0", message: "Something went wrong")]])),
    reducer: { AppReducer() }
  )
  return BaseAppScreen(
    store: store
  ) {
    CatFactsListView(store: store.scope(state: \.catFacts.viewModel, action: \.catFacts.viewModel))
  }
}
