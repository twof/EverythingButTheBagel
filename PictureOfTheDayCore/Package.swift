// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "PictureOfTheDayCore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17), .macOS(.v14)
  ],
  products: [
    .library(
      name: "PictureOfTheDayCore",
      targets: ["PictureOfTheDayCore"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.10.0"
    ),
    .package(url: "https://github.com/twof/FunctionSpy", branch: "main"),
    .package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "2.0.0"),
    .package(path: "../EverythingButTheBagelCore"),
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")
  ],
  targets: [
    .target(
      name: "PictureOfTheDayCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(name: "SwiftDotenv", package: "swift-dotenv"),
        .product(name: "EverythingButTheBagelCore", package: "EverythingButTheBagelCore")
      ]
      ,
      resources: [
        .copy("prod.env")
      ],
      plugins: [
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint"),
        .plugin(name: "LocalizationProcessing")
      ]
    ),
    .executableTarget(
      name: "ProcessStringCatalogs"
    ),
    .plugin(
      name: "LocalizationProcessing",
      capability: .buildTool(),
      dependencies: [
        "ProcessStringCatalogs"
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
    )
  ]
)
