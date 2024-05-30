import SwiftUI
import ComposableArchitecture
import PictureOfTheDayCore
import Sprinkles
import EverythingButTheBagelCore

public struct POTDDetailView: View {
  let store: StoreOf<PictureOfTheDayDetailVM>
  let imageStore: StoreOf<AsyncImageViewModel>

  public init(
    store: StoreOf<PictureOfTheDayDetailVM>,
    imageStore: StoreOf<AsyncImageViewModel>
  ) {
    self.store = store
    self.imageStore = imageStore
  }

  public var body: some View {
    VStack(alignment: .leading) {
      AsyncImageLoader(store: imageStore)
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 300)

      Text(store.title)
        .font(.title)

      Text(store.description)
    }
  }
}

// Configurable preview
#Preview {
  POTDDetailView(
    store: Store(
      initialState: PictureOfTheDayDetailVM.State(
        title: "Hello world",
        description: "A very long string"
      ), reducer: {
        PictureOfTheDayDetailVM()
      }
    ),
    imageStore: Store(
      initialState: AsyncImageViewModel.State(),
      reducer: {
        AsyncImageViewModel()
      }
    )
  )
}

// Live content
#Preview {
  let base = Store(
    initialState: PictureOfTheDayDetailBase.State(
      asyncImage: AsyncImageBase.State(
        imageUrl: URL(
          string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg"
        )!
      ),
      viewModel: PictureOfTheDayDetailVM.State(
        title: "Hello world",
        description: "A long description"
      )
    )) {
      PictureOfTheDayDetailBase()
    }

  return POTDDetailView(
    store: base.scope(state: \.viewModel, action: \.viewModel),
    imageStore: base
      .scope(state: \.asyncImage, action: \.asyncImage)
      .scope(state: \.viewModel, action: \.viewModel)
  )
}
