// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Sprinkles",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "Sprinkles",
      targets: ["Sprinkles"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/markiv/SwiftUI-Shimmer", branch: "main"),
    .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.10"),
    .package(url: "https://github.com/Giphy/giphy-ios-sdk", from: "2.2.9"),
    .package(path: "../EverythingButTheBagelCore")
  ],
  targets: [
    .target(
      name: "Sprinkles",
      dependencies: [
        .product(name: "Shimmer", package: "SwiftUI-Shimmer"),
        .product(name: "GiphyUISDK", package: "giphy-ios-sdk"),
        "EverythingButTheBagelCore"
      ]
    ),
    .testTarget(
      name: "SprinklesTests",
      dependencies: [
        "Sprinkles",
        .product(name: "ViewInspector", package: "ViewInspector")
      ]
    )
  ],
  swiftLanguageVersions: [.v6]
)
