import EverythingButTheBagelCore

extension PictureOfTheDayItemBase.State: ViewModelPlaceholders {
  public static var placeholders: [PictureOfTheDayItemBase.State] {
    (0...20).map { index in
      .init(
        title: "A very long string, A very long string, A very long string, \(index)",
        asyncImage: .mock
      )
    }
  }
}
