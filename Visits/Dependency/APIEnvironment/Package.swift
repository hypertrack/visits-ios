// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "APIEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "APIEnvironment", targets: ["APIEnvironment"]),
    .library(name: "APIEnvironmentLive", targets: ["APIEnvironmentLive"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.9.0")),
    .package(path: "Coordinate"),
    .package(path: "Credentials"),
    .package(path: "DeviceID"),
    .package(path: "History"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.9")),
    .package(path: "PublishableKey"),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "APIEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Coordinate",
        "Credentials",
        "DeviceID",
        "History",
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "Prelude",
        "PublishableKey",
        "Visit"
      ]
    ),
    .target(name: "APIEnvironmentLive", dependencies: ["APIEnvironment"]),
  ]
)
