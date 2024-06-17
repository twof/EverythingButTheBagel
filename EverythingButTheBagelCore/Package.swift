// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "EverythingButTheBagelCore",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "EverythingButTheBagelCore",
      targets: ["EverythingButTheBagelCore"]
    ),
    .library(
      name: "GarlicTestUtils",
      targets: ["GarlicTestUtils"]
    ),

    .library(
      name: "Sprinkles",
      targets: ["Sprinkles"]
    ),

    .library(
      name: "PictureOfTheDayCore",
      targets: ["PictureOfTheDayCore"]
    ),
    .library(
      name: "PictureOfTheDayUI",
      targets: ["PictureOfTheDayUI"]
    ),

    .library(
      name: "CatFactsCore",
      targets: ["CatFactsCore"]
    ),
    .library(
      name: "CatFactsUI",
      targets: ["CatFactsUI"]
    ),

    .library(
      name: "AppCore",
      targets: ["AppCore"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.10.0"
    ),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.23.0"),
    .package(url: "https://github.com/twof/FunctionSpy", branch: "main"),
    .package(url: "https://github.com/twof/ControllableScrollView", from: "1.0.0"),
    .package(url: "https://github.com/markiv/SwiftUI-Shimmer", branch: "main"),
    .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.10"),
    .package(url: "https://github.com/Giphy/giphy-ios-sdk", from: "2.2.9"),
    .package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "2.0.0"),
  ],
  targets: [
    // MARK: Core
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
    ),

    // MARK: Sprinkles
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
      ]
    ),

    // MARK: PictureOfTheDay
    .target(
      name: "PictureOfTheDayCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(name: "SwiftDotenv", package: "swift-dotenv"),
        "EverythingButTheBagelCore"
      ],
      resources: [
        .copy("prod.env")
      ],
      plugins: [
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
    ),
    .target(
      name: "PictureOfTheDayUI",
      dependencies: [
        "PictureOfTheDayCore",
        "Sprinkles"
      ]
    ),

    // MARK: CatFacts
    .target(
      name: "CatFactsCore",
      dependencies: [
        "EverythingButTheBagelCore"
      ],
      resources: [
        .process("Localizable.xcstrings")
      ]
    ),
    .testTarget(
      name: "CatFactsUnitTests",
      dependencies: [
        "CatFactsCore",
        "GarlicTestUtils"
      ]
    ),
    .testTarget(
      name: "CatFactsIntegrationTests",
      dependencies: [
        "CatFactsCore",
        "GarlicTestUtils"
      ]
    ),
    .target(
      name: "CatFactsUI",
      dependencies: [
        "CatFactsCore",
        "EverythingButTheBagelCore",
        "Sprinkles"
      ]
    ),

    // MARK: AppCore
    .target(
      name: "AppCore",
      dependencies: [
        "EverythingButTheBagelCore",
        "CatFactsCore",
        "PictureOfTheDayCore"
      ]
    ),
    .testTarget(
      name: "AppUnitTests",
      dependencies: [
        "AppCore"
      ]
    ),
    .testTarget(
      name: "AppIntegrationTests",
      dependencies: [
        "AppCore"
      ]
    )
  ],
  swiftLanguageVersions: [.v6]
)
