// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "EverythingButTheBagelCore",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "EverythingButTheBagelCore",
      targets: ["EverythingButTheBagelCore"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      branch: "shared-state-beta"
    ),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.22.2"),
    .package(url: "https://github.com/twof/FunctionSpy", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "EverythingButTheBagelCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(name: "Sentry", package: "sentry-cocoa")
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
