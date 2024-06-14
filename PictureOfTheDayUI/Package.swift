// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "PictureOfTheDayUI",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "PictureOfTheDayUI",
      targets: ["PictureOfTheDayUI"]
    )
  ],
  dependencies: [
    .package(path: "../PictureOfTheDayCore"),
    .package(path: "../Sprinkles")
  ],
  targets: [
    .target(
      name: "PictureOfTheDayUI",
      dependencies: [
        "PictureOfTheDayCore",
        "Sprinkles"
      ]
    )
  ],
  swiftLanguageVersions: [.v6]
)
