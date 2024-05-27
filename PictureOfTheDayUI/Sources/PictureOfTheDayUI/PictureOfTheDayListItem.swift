import SwiftUI
import Shimmer
import PictureOfTheDayCore
@_spi(Internals) import ComposableArchitecture
import EverythingButTheBagelCore
import Sprinkles

public struct PictureOfTheDayTextBase: View {
  let store: StoreOf<PictureOfTheDayItemBase>

  public var body: some View {
    PictureOfTheDayText(
      store: store.scope(state: \.viewModel, action: \.viewModel)
    )
  }
}

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

public struct PictureOfTheDayListItem: View {
  let text: PictureOfTheDayText
  let image: AsyncImageLoader

  public init(text: PictureOfTheDayText, image: AsyncImageLoader) {
    self.text = text
    self.image = image
  }

  public var body: some View {
    HStack(alignment: .top) {
      image
        .frame(width: 100, height: 100)
      text

      Spacer()
    }
    .padding()
  }
}

// struct POTDListViewBase: View {
//  let store: StoreOf<POTDListAttemptBase>
//
//  var body: some View {
//    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
//  }
// }
//
// struct POTDListView: View {
//  let store: StoreOf<POTDListAttemptBase>
//
//  var body: some View {
//    List {
//      ForEachStore(store.scope(state: \.elements, action: \.element)) { store in
//        PictureOfTheDayListItem(
//          store: store.scope(state: \.viewModel, action: \.viewModel)
////          ,
////          asyncImage: store.scope(
////            state: \.asyncImage.viewModel,
////            action: \.asyncImage.viewModel
////          )
//        )
//      }
//    }
//  }
// }

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
  static let mock = PictureOfTheDayListItem(text: .longMock, image: .mock)

  static let loadingPlaceholder: some View = PictureOfTheDayListItem(text: .longMock, image: .mock)
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
      asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
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
      asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
    ),
    reducer: {
      PictureOfTheDayItemBase()
    }
  )
  let textView = PictureOfTheDayText(
    store: store.scope(state: \.viewModel, action: \.viewModel)
  )

  let imageView = AsyncImageLoader(store: store.scope(state: \.asyncImage.viewModel, action: \.asyncImage.viewModel))

  return PictureOfTheDayListItem(text: textView, image: imageView)
}

//
// #Preview {
//  let store = Store(initialState: POTDListAttemptBase.State(elements: [
//    .init(title: "hello", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)),
//    .init(title: "world", asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!))
//  ])) {
//    POTDListAttemptBase()
//  }
//
//  return POTDListView(store: store)
// }
