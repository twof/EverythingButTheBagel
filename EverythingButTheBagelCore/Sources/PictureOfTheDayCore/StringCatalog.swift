import Foundation

public extension URL {
  static var pictureOfTheDayStringCatalog: URL {
    let module = Bundle.module
    // This is being loaded as JSON because Xcode refuses to copy .xcstrings files into the bundle
    // SPM will actually do this, so it appears to be an Xcode specific bug. To work around that
    // a build plugin is included in this package which copies the contents of
    // Localizable.xcstrings to a new file called Localizable.json, which Xcode is happy to
    // copy into the bundle.
    return module.url(forResource: "Localizable", withExtension: "json")!
  }
}
