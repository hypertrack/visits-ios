// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "PasteboardEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "PasteboardEnvironment", targets: ["PasteboardEnvironment"]),
    .library(name: "PasteboardEnvironmentLive", targets: ["PasteboardEnvironmentLive"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.13.0")),
    .package(path: "Log"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4"))
  ],
  targets: [
    .target(
      name: "PasteboardEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "NonEmpty", package: "swift-nonempty")
      ]
    ),
    .target(name: "PasteboardEnvironmentLive", dependencies: ["Log", "PasteboardEnvironment"])
  ]
)
