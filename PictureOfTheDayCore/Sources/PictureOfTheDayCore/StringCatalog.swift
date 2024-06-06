import Foundation

public extension URL {
  static var pictureOfTheDayStringCatalog: URL {
    let module = Bundle.module
    print(module.bundleURL)
    print(module.resourceURL)
    return module.url(forResource: "Localizable", withExtension: "json")!
//    URL(fileURLWithPath: #file).deletingLastPathComponent().appending(path: "Localizable.xcstrings")
  }
}
