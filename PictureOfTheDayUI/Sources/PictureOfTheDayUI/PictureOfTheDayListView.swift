import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles
import PictureOfTheDayCore

// swiftlint:disable:next identifier_name
@ViewBuilder public func PictureOfTheDayListView(store: StoreOf<PictureOfTheDayViewModelReducer>) -> some View {
  GenericListView(store: store) { fact in
    PictureOfTheDayListItem(vm: fact)
  }
}

// Configurable preview
#Preview {
  PictureOfTheDayListView(
    store: Store(
      initialState: PictureOfTheDayViewModelReducer.State(),
      reducer: {
        PictureOfTheDayViewModelReducer.potd
      }
    )
  )
  .preferredColorScheme(.dark)
  .environment(\.locale, .init(identifier: "es"))
}

// Preview with live dependencies
#Preview {
  let store = Store(
    initialState: PictureOfTheDayBase.State(),
    reducer: { PictureOfTheDayBase.potd }
  )
  return PictureOfTheDayListView(
    store: store.scope(state: \.viewModel, action: \.viewModel)
  )
}
