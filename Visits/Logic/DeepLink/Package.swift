// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "DeepLink",
  platforms: [.iOS(.v13)],
  products: [.library(name: "DeepLink", targets: ["DeepLink"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.15.0")),
    .package(path: "DeepLinkEnvironment"),
    .package(path: "DriverID"),
    .package(path: "ManualVisitsStatus"),
    .package(path: "NetworkEnvironment"),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.12")),
    .package(path: "PublishableKey"),
    .package(path: "RestorationState"),
    .package(path: "SDK")
  ],
  targets: [
    .target(
      name: "DeepLink",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DeepLinkEnvironment",
        "DriverID",
        "ManualVisitsStatus",
        "NetworkEnvironment",
        "Prelude",
        "PublishableKey",
        "RestorationState",
        "SDK"
      ]
    ),
    .testTarget(
      name: "DeepLinkTests",
      dependencies: ["DeepLink"]
    ),
  ]
)
