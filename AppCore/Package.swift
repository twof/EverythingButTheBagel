// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "AppCore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "AppCore",
      targets: ["AppCore"]
    )
  ],
  dependencies: [
    .package(path: "../EverythingButTheBagelCore"),
    .package(path: "../CatFactsCore"),
    .package(path: "../PictureOfTheDayCore")
  ],
  targets: [
    .target(
      name: "AppCore",
      dependencies: [
        .product(name: "EverythingButTheBagelCore", package: "EverythingButTheBagelCore"),
        .product(name: "CatFactsCore", package: "CatFactsCore"),
        .product(name: "PictureOfTheDayCore", package: "PictureOfTheDayCore")
      ]
    ),
    .testTarget(
      name: "AppUnitTests",
      dependencies: [
        "AppCore"
      ]
    ),
    .testTarget(
      name: "AppIntegrationTests",
      dependencies: [
        "AppCore"
      ]
    )
  ],
  swiftLanguageVersions: [.v6]
)
