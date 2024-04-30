import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public typealias PictureOfTheDayViewModelReducer = ListFeatureViewModelReducer<PictureOfTheDayViewModel, POTDPath>

public extension PictureOfTheDayViewModelReducer {
  static var potd: PictureOfTheDayViewModelReducer {
    PictureOfTheDayViewModelReducer()
  }
}

public extension PictureOfTheDayViewModelReducer.State {
  init() {
    self.init(
      emptyListMessage: LocalizedTextState(
        text: String(
          localized: "No pictures here! Pull to refresh to check again.",
          bundle: .module,
          comment: "Message to let the user know that there are no list items, but not due to an error."
        ),
        stringCatalogLocation: .pictureOfTheDayStringCatalog
      )
    )
  }
}
