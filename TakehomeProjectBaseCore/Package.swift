// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "TakehomeProjectBaseCore",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "TakehomeProjectBaseCore",
      targets: ["TakehomeProjectBaseCore"])
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
      name: "TakehomeProjectBaseCore",
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
        "TakehomeProjectBaseCore"
      ]
    ),
    .testTarget(
      name: "IntegrationTests",
      dependencies: [
        "FunctionSpy",
        "TakehomeProjectBaseCore"
      ]
    )
  ]
)
