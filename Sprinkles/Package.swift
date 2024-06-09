// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Sprinkles",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
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
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
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
      ])
  ]
)
