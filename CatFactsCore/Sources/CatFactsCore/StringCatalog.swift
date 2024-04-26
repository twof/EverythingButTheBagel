import Foundation

public extension URL {
  static var catFactsStringCatalog: URL {
    URL(fileURLWithPath: #file).deletingLastPathComponent().appending(path: "Localizable.xcstrings")
  }
}
