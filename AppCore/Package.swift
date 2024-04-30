// swift-tools-version: 5.10

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
    .package(path: "../CatFactsCore")
  ],
  targets: [
    .target(
      name: "AppCore",
      dependencies: [
        .product(name: "EverythingButTheBagelCore", package: "EverythingButTheBagelCore"),
        .product(name: "CatFactsCore", package: "CatFactsCore")
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
  ]
)
