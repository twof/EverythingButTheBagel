import SwiftUI
import EverythingButTheBagelCore
import ComposableArchitecture
import AppCore
import Sprinkles
import CatFactsUI

/// Containter view that holds content, but displayes global information like errors
/// and connection status
struct BaseAppScreen<InnerView: View>: View {
  @Bindable var store: StoreOf<ErrorIndicatorViewModel>
  @ViewBuilder var view: () -> InnerView

  public init(
    store: StoreOf<ErrorIndicatorViewModel>,
    @ViewBuilder view: @escaping () -> InnerView
  ) {
    self.store = store
    self.view = view
  }

  var body: some View {
    view()
      .withError(vm: store.state.error())
  }
}

// Live preview. Hits network.
#Preview {
  let store = Store(
    initialState: AppReducer.State(errors: .init(errors: ["anything": [.init(id: UUID(), message: "Something went wrong")]])),
    reducer: { AppReducer() }
  )
  return BaseAppScreen(
    store: store.scope(state: \.errors, action: \.errors)
  ) {
    CatFactsListView(store: store.scope(state: \.catFacts.viewModel, action: \.catFacts.viewModel))
  }
}
