// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "DeepLinkEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "DeepLinkEnvironment", targets: ["DeepLinkEnvironment"]),
    .library(name: "DeepLinkEnvironmentLive", targets: ["DeepLinkEnvironmentLive"])
  ],
  dependencies: [
    .package(name: "Branch", url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", .exact("0.37.0")),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.15.0")),
    .package(path: "DriverID"),
    .package(path: "Log"),
    .package(path: "ManualVisitsStatus"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(path: "PublishableKey")
  ],
  targets: [
    .target(
      name: "DeepLinkEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DriverID",
        "ManualVisitsStatus",
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "PublishableKey"
      ]
    ),
    .target(
      name: "DeepLinkEnvironmentLive",
      dependencies: [
        "Branch",
        "DeepLinkEnvironment",
        "Log"
      ]
    ),
    .testTarget(
      name: "DeepLinkEnvironmentLiveTests",
      dependencies: ["DeepLinkEnvironmentLive"]
    )
  ]
)
