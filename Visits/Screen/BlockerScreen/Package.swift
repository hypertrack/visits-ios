// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "BlockerScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "BlockerScreen", targets: ["BlockerScreen"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.14.0")),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6")),
    .package(name: "Tagged", url: "https://github.com/pointfreeco/swift-tagged", .exact("0.5.0"))
  ],
  targets: [
    .target(
      name: "BlockerScreen",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "Tagged",
        "Views"
      ]
    )
  ]
)
