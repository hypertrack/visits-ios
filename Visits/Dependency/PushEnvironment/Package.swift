// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "PushEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "PushEnvironment", targets: ["PushEnvironment"]),
    .library(name: "PushEnvironmentLive", targets: ["PushEnvironmentLive"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.13.0")),
    .package(path: "Log")
  ],
  targets: [
    .target(
      name: "PushEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(name: "PushEnvironmentLive", dependencies: ["Log", "PushEnvironment"])
  ]
)
