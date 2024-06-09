import Foundation

// TODO: This isn't right. Replace with bundle.
public extension URL {
  static func stringCatalog(file: String = #file) -> URL {
    URL(fileURLWithPath: file).deletingLastPathComponent().appending(path: "Localizable.xcstrings")
  }
}
