// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "HapticFeedbackEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "HapticFeedbackEnvironment", targets: ["HapticFeedbackEnvironment"]),
    .library(name: "HapticFeedbackEnvironmentLive", targets: ["HapticFeedbackEnvironmentLive"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.11.0")),
    .package(path: "Log"),
  ],
  targets: [
    .target(
      name: "HapticFeedbackEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(name: "HapticFeedbackEnvironmentLive", dependencies: ["HapticFeedbackEnvironment", "Log"])
  ]
)
