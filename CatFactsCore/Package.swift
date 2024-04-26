// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "CatFactsCore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "CatFactsCore",
      targets: ["CatFactsCore"]
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
    .package(path: "../EverythingButTheBagelCore")
  ],
  targets: [
    .target(
      name: "CatFactsCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(name: "Sentry", package: "sentry-cocoa"),
        .product(name: "ControllableScrollView", package: "controllablescrollview"),
        .product(name: "EverythingButTheBagelCore", package: "EverythingButTheBagelCore")
      ],
      resources: [
        .process("Localizable.xcstrings")
      ]
    ),
    .testTarget(
      name: "CatFactsUnitTests",
      dependencies: [
        "FunctionSpy",
        "CatFactsCore",
        .product(name: "GarlicTestUtils", package: "EverythingButTheBagelCore")
      ]
    ),
    .testTarget(
      name: "CatFactsIntegrationTests",
      dependencies: [
        "FunctionSpy",
        "CatFactsCore",
        .product(name: "GarlicTestUtils", package: "EverythingButTheBagelCore")
      ]
    )
  ]
)
