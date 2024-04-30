import ComposableArchitecture
import Foundation
import EverythingButTheBagelCore

public typealias PictureOfTheDayViewModelReducer = ChildListFeatureVMReducer<PictureOfTheDayViewModel, [POTDResponseModel], POTDPath>

public extension PictureOfTheDayViewModelReducer {
  static var potd: PictureOfTheDayViewModelReducer {
    PictureOfTheDayViewModelReducer { response in
      response.map(PictureOfTheDayViewModel.init(model:))
    }
  }
}

public extension PictureOfTheDayViewModelReducer.State {
  init() {
    self.init(
      list: .init(
        emptyListMessage: LocalizedTextState(
          text: String(
            localized: "No pictures here! Pull to refresh to check again.",
            bundle: .module,
            comment: "Message to let the user know that there are no list items, but not due to an error."
          ),
          stringCatalogLocation: .pictureOfTheDayStringCatalog
        )
      )
    )
  }
}
