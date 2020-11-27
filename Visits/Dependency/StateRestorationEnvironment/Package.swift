// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "StateRestorationEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "StateRestorationEnvironment", targets: ["StateRestorationEnvironment"]),
    .library(name: "StateRestorationEnvironmentLive", targets: ["StateRestorationEnvironmentLive"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.9.0")),
    .package(path: "Credentials"),
    .package(path: "DriverID"),
    .package(path: "Log"),
    .package(path: "ManualVisitsStatus"),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.11")),
    .package(path: "PublishableKey"),
    .package(path: "RestorationState"),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "StateRestorationEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Credentials",
        "DriverID",
        "ManualVisitsStatus",
        "Prelude",
        "PublishableKey",
        "RestorationState",
        "Visit"
      ]
    ),
    .target(
      name: "StateRestorationEnvironmentLive",
      dependencies: ["Log", "StateRestorationEnvironment"]
    )
  ]
)
