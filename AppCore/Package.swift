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
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      branch: "shared-state-beta"
    ),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.23.0"),
    .package(url: "https://github.com/twof/FunctionSpy", branch: "main"),
    .package(url: "https://github.com/twof/ControllableScrollView", from: "1.0.0"),
    .package(path: "../EverythingButTheBagelCore"),
    .package(path: "../CatFactsCore")
  ],
  targets: [
    .target(
      name: "AppCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(name: "Sentry", package: "sentry-cocoa"),
        .product(name: "ControllableScrollView", package: "controllablescrollview"),
        .product(name: "EverythingButTheBagelCore", package: "EverythingButTheBagelCore"),
        .product(name: "CatFactsCore", package: "CatFactsCore")
      ]
    ),
    .testTarget(
      name: "AppUnitTests",
      dependencies: [
        "FunctionSpy",
        "AppCore"
      ]
    ),
    .testTarget(
      name: "AppIntegrationTests",
      dependencies: [
        "FunctionSpy",
        "AppCore"
      ]
    )
  ]
)
