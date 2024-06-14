// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "CatFactsUI",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "CatFactsUI",
      targets: ["CatFactsUI"]
    )
  ],
  dependencies: [
    .package(path: "../CatFactsCore"),
    .package(path: "../EverythingButTheBagelCore"),
    .package(path: "../Sprinkles")
  ],
  targets: [
    .target(
      name: "CatFactsUI",
      dependencies: [
        "CatFactsCore",
        "EverythingButTheBagelCore",
        "Sprinkles"
      ]
    )
  ],
  swiftLanguageVersions: [.v6]
)
