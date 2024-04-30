import EverythingButTheBagelCore
import Foundation
import IdentifiedCollections

public struct PictureOfTheDayViewModel: Codable, Equatable, Identifiable {
  public var id: String { title }
  public let title: String
  public var thumbnailData: Data?

  public init(title: String) {
    self.title = title
  }
}

extension PictureOfTheDayViewModel: ViewModelPlaceholders {
  public static let placeholders = (0..<20).map {
    PictureOfTheDayViewModel(
      title: "Example of a long fact Example of a long fact Example of a long fact"
      + "Example of a long fact Example of a long fact Example of a long fact Example of a long"
      + "fact Example of a long fact \($0)"
    )
  }
}

extension PictureOfTheDayViewModel: ViewModelConvertable {
  public init(model: POTDResponseModel) {
    self.title = model.title
  }
}

extension IdentifiedArrayOf<PictureOfTheDayViewModel> {
  public static let placeholders = PictureOfTheDayViewModel.placeholders.toIdentifiedArray
}
