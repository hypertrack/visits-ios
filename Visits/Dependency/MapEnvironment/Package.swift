// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "MapEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "MapEnvironment", targets: ["MapEnvironment"]),
    .library(name: "MapEnvironmentLive", targets: ["MapEnvironmentLive"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.9.0")),
    .package(path: "Coordinate"),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.9")),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "MapEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Coordinate",
        "Prelude",
        "Visit"
      ]
    ),
    .target(name: "MapEnvironmentLive", dependencies: ["MapEnvironment"])
  ]
)
