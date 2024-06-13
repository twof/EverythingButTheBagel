import SwiftUI
import Shimmer
import PictureOfTheDayCore
@_spi(Internals) import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles

public struct PictureOfTheDayText: View {
  let store: StoreOf<PictureOfTheDayItemViewModel>

  public init(
    store: StoreOf<PictureOfTheDayItemViewModel>
  ) {
    self.store = store
  }

  public var body: some View {
    Text(store.title)
      .font(.body)
  }
}

public struct PictureOfTheDayListItem: View, Equatable {
//  let text: PictureOfTheDayText
//  let image: AsyncImageLoader
  let stores: POTDItemStores

//  public init(text: PictureOfTheDayText, image: AsyncImageLoader) {
//    self.text = text
//    self.image = image
//  }

//  public init(stores: POTDItemStores) {
//    self.text = PictureOfTheDayText(store: stores.cellContent)
//    self.image = AsyncImageLoader(store: stores.asyncImage)
//  }

  public var body: some View {
    HStack(alignment: .top) {
      AsyncImageLoader(store: stores.asyncImage)
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)

      PictureOfTheDayText(store: stores.cellContent)

      Spacer()
    }
    .padding()
  }
}

public extension PictureOfTheDayText {
  static let loadingPlaceholder: some View = longMock
    .redacted(reason: .placeholder)
    .shimmering()
    .accessibilityLabel("Loading")

  static let longMock = PictureOfTheDayText(
    store: .init(
      initialState: PictureOfTheDayItemViewModel.State(
        title: "Example of a long cat fact, Example of a long cat fact,"
        + "Example of a long cat fact, Example of a long cat fact"
      ),
      reducer: {
        PictureOfTheDayItemViewModel()
      }
    )
  )
}

public extension PictureOfTheDayListItem {
  static let mock = PictureOfTheDayListItem(stores: .loadingMock(id: "10"))

  static let loadingPlaceholder: some View = mock
    .redacted(reason: .placeholder)
    .shimmering()
    .accessibilityLabel("Loading")
}

#Preview {
  Group {
    PictureOfTheDayListItem.mock

    PictureOfTheDayListItem.loadingPlaceholder
  }
}

// Live preview
#Preview {
  let store = Store(
    initialState: PictureOfTheDayItemBase.State(
      title: "Hey this is an image",
      asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!, imageName: "Ryugu01_Rover1aHayabusa2_960.jpg")
    ),
    reducer: {
      PictureOfTheDayItemBase()
    }
  )

  return PictureOfTheDayText(
    store: store.scope(state: \.viewModel, action: \.viewModel)
  )
}

#Preview {
  let store = Store(
    initialState: PictureOfTheDayItemBase.State(
      title: "Hey this is an image",
      asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!, imageName: "Ryugu01_Rover1aHayabusa2_960.jpg")
    ),
    reducer: {
      PictureOfTheDayItemBase()
    }
  )

  let listStores = POTDItemStores(cellContent: store.scope(state: \.viewModel, action: \.viewModel), asyncImage: store.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel))

  return PictureOfTheDayListItem(stores: listStores)
}
