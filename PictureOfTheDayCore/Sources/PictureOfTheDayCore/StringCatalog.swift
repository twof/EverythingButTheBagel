import Foundation

public extension URL {
  static var pictureOfTheDayStringCatalog: URL {
    let module = Bundle.module
    return module.url(forResource: "Localizable", withExtension: "json")!
  }
}
