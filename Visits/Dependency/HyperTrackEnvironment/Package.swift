// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "HyperTrackEnvironment",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "HyperTrackEnvironment", targets: ["HyperTrackEnvironment"]),
    .library(name: "HyperTrackEnvironmentLive", targets: ["HyperTrackEnvironmentLive"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .exact("0.9.0")
    ),
    .package(path: "DeviceID"),
    .package(path: "DriverID"),
    .package(
      name: "HyperTrack",
      url: "https://github.com/hypertrack/sdk-ios",
      .exact("4.6.0")
    ),
    .package(path: "Log"),
    .package(
      url: "https://github.com/pointfreeco/swift-nonempty",
      .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")
    ),
    .package(
      name: "Prelude",
      url: "https://github.com/hypertrack/prelude-swift",
      .exact("0.0.10")
    ),
    .package(path: "PublishableKey"),
    .package(path: "SDK"),
    .package(
      name: "Tagged",
      url: "https://github.com/pointfreeco/swift-tagged",
      .exact("0.5.0")
    ),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "HyperTrackEnvironment",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        "DeviceID",
        "DriverID",
        "Prelude",
        "PublishableKey",
        "SDK",
        "Visit"
      ]
    ),
    .target(
      name: "HyperTrackEnvironmentLive",
      dependencies: [
        "HyperTrack",
        "HyperTrackEnvironment",
        "Log",
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "Tagged"
      ]
    )
  ]
)
