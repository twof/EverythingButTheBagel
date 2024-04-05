// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "EverythingButTheBagelCore",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "EverythingButTheBagelCore",
      targets: ["EverythingButTheBagelCore"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.0.0"
    ),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.23.0"),
    .package(url: "https://github.com/twof/FunctionSpy", branch: "main"),
    .package(url: "https://github.com/twof/ControllableScrollView", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "EverythingButTheBagelCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(name: "Sentry", package: "sentry-cocoa"),
        .product(name: "ControllableScrollView", package: "controllablescrollview")
      ]
    ),
    .testTarget(
      name: "UnitTests",
      dependencies: [
        "FunctionSpy",
        "EverythingButTheBagelCore"
      ]
    ),
    .testTarget(
      name: "IntegrationTests",
      dependencies: [
        "FunctionSpy",
        "EverythingButTheBagelCore"
      ]
    )
  ]
)
