import Foundation

public extension URL {
  static func stringCatalog(file: String = #file) -> URL {
    URL(fileURLWithPath: file).deletingLastPathComponent().appending(path: "Localizable.xcstrings")
  }
}
