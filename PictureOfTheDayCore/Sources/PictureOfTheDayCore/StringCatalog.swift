import Foundation

public extension URL {
  static var pictureOfTheDayStringCatalog: URL {
    URL(fileURLWithPath: #file).deletingLastPathComponent().appending(path: "Localizable.xcstrings")
  }
}
