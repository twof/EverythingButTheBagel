// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TakehomeProjectBaseCore",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "TakehomeProjectBaseCore",
      targets: ["TakehomeProjectBaseCore"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.0.0"
    )
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "TakehomeProjectBaseCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        )
      ]
    ),
    .testTarget(
      name: "UnitTests",
      dependencies: ["TakehomeProjectBaseCore"]),
    .testTarget(
      name: "IntegrationTests",
      dependencies: ["TakehomeProjectBaseCore"]),
  ]
)
