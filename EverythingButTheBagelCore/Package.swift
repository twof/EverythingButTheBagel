// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "EverythingButTheBagelCore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "EverythingButTheBagelCore",
      targets: ["EverythingButTheBagelCore"]
    ),
    .library(
      name: "GarlicTestUtils",
      targets: ["GarlicTestUtils"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.10.0"
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
    .target(
      name: "GarlicTestUtils",
      dependencies: [
        "EverythingButTheBagelCore"
      ]
    ),
    .testTarget(
      name: "UnitTests",
      dependencies: [
        "FunctionSpy",
        "EverythingButTheBagelCore",
        "GarlicTestUtils"
      ],
      resources: [
        .process("Localizable.xcstrings")
      ]
    ),
    .testTarget(
      name: "IntegrationTests",
      dependencies: [
        "FunctionSpy",
        "EverythingButTheBagelCore",
        "GarlicTestUtils"
      ]
    )
  ]
)
