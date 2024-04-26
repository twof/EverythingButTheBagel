// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PictureOfTheDayCore",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v17), .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PictureOfTheDayCore",
            targets: ["PictureOfTheDayCore"])
    ],
    dependencies: [
      .package(
        url: "https://github.com/pointfreeco/swift-composable-architecture",
        branch: "shared-state-beta"
      ),
      .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.23.0"),
      .package(url: "https://github.com/twof/FunctionSpy", branch: "main"),
      .package(url: "https://github.com/twof/ControllableScrollView", from: "1.0.0"),
      .package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "2.0.0"),
      .package(path: "../EverythingButTheBagelCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PictureOfTheDayCore",
            dependencies: [
              .product(
                name: "ComposableArchitecture",
                package: "swift-composable-architecture"
              ),
              .product(name: "Sentry", package: "sentry-cocoa"),
              .product(name: "ControllableScrollView", package: "controllablescrollview"),
              .product(name: "SwiftDotenv", package: "swift-dotenv"),
              .product(name: "EverythingButTheBagelCore", package: "EverythingButTheBagelCore")
            ],
            resources: [
              .process("prod.env")
            ]
        ),
        .testTarget(
          name: "PictureOfTheDayUnitTests",
          dependencies: [
            "FunctionSpy",
            "PictureOfTheDayCore"
          ]
        ),
        .testTarget(
          name: "PictureOfTheDayIntegrationTests",
          dependencies: [
            "FunctionSpy",
            "PictureOfTheDayCore"
          ]
//          resources: [
//            .process("prod.env")
//          ]
        )
    ]
)
