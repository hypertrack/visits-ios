// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "NetworkEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "NetworkEnvironment", targets: ["NetworkEnvironment"]),
    .library(name: "NetworkEnvironmentLive", targets: ["NetworkEnvironmentLive"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.15.0")),
    .package(path: "Log")
  ],
  targets: [
    .target(
      name: "NetworkEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(name: "NetworkEnvironmentLive", dependencies: ["Log", "NetworkEnvironment"])
  ]
)
