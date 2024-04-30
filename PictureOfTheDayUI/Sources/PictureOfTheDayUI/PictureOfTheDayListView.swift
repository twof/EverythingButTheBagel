import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles
import PictureOfTheDayCore

// swiftlint:disable:next identifier_name
@ViewBuilder public func PictureOfTheDayListView(
  store: StoreOf<PictureOfTheDayViewModelReducer>
) -> some View {
  GenericListView(
    store: store
  ) { picture in
    PictureOfTheDayListItem(viewModel: picture)
  }
  .destination { store in
    switch store.case {
    case let .detail(detail):
      POTDDetailView(
        store: detail.scope(state: \.viewModel, action: \.viewModel),
        imageStore: detail
          .scope(state: \.asyncImage, action: \.asyncImage)
          .scope(state: \.viewModel, action: \.viewModel)
      )
    }
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
