// swift-tools-version: 6.0

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
    .package(path: "../EverythingButTheBagelCore")
  ],
  targets: [
    .target(
      name: "CatFactsCore",
      dependencies: [
        .product(name: "EverythingButTheBagelCore", package: "EverythingButTheBagelCore")
      ],
      resources: [
        .process("Localizable.xcstrings")
      ]
    ),
    .testTarget(
      name: "CatFactsUnitTests",
      dependencies: [
        "CatFactsCore",
        .product(name: "GarlicTestUtils", package: "EverythingButTheBagelCore")
      ]
    ),
    .testTarget(
      name: "CatFactsIntegrationTests",
      dependencies: [
        "CatFactsCore",
        .product(name: "GarlicTestUtils", package: "EverythingButTheBagelCore")
      ]
    )
  ],
  swiftLanguageVersions: [.v6]
)
