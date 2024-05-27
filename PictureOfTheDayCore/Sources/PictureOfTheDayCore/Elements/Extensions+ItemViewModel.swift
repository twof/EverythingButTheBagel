import EverythingButTheBagelCore
import IdentifiedCollections

extension PictureOfTheDayItemViewModel.State: ViewModelPlaceholders {
  public static let placeholders = (0..<20).map {
    PictureOfTheDayItemViewModel.State(
      title: "Example of a long fact Example of a long fact Example of a long fact"
      + "Example of a long fact Example of a long fact Example of a long fact Example of a long"
      + "fact Example of a long fact \($0)"
//      ,
//      asyncImage: .init(.init(isLoading: false))
    )
  }
}

// TODO: This no longer makes sense because the response model holds a URL which needs
// to be passed to an AsyncImageBase so it can start the loading process
extension PictureOfTheDayItemViewModel.State: ViewModelConvertable {
  public init(model: POTDResponseModel) {
    self.init(
      title: model.title
//      , asyncImage: .init(.init(isLoading: false))
    )
  }
}

extension IdentifiedArrayOf<PictureOfTheDayItemViewModel.State> {
  public static let placeholders = PictureOfTheDayItemViewModel.State.placeholders.toIdentifiedArray
}
