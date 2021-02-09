// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "App",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "App", targets: ["App"]),
    .library(name: "AppLive", targets: ["AppLive"])
  ],
  dependencies: [
    .package(path: "APIEnvironment"),
    .package(path: "Architecture"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.13.0")),
    .package(path: "Credentials"),
    .package(path: "DeepLink"),
    .package(path: "DeepLinkEnvironment"),
    .package(path: "DeviceID"),
    .package(path: "DriverID"),
    .package(path: "HapticFeedbackEnvironment"),
    .package(path: "History"),
    .package(path: "HyperTrackEnvironment"),
    .package(path: "ManualVisitsStatus"),
    .package(path: "MapEnvironment"),
    .package(path: "NetworkEnvironment"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(path: "PasteboardEnvironment"),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.12")),
    .package(path: "PublishableKey"),
    .package(path: "PushEnvironment"),
    .package(path: "PushStatus"),
    .package(path: "RestorationState"),
    .package(path: "SDK"),
    .package(path: "StateRestorationEnvironment"),
    .package(path: "TabSelection"),
    .package(name: "Tagged", url: "https://github.com/pointfreeco/swift-tagged", .exact("0.5.0")),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        "APIEnvironment",
        "Architecture",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Credentials",
        "DeepLink",
        "DeepLinkEnvironment",
        "DeviceID",
        "DriverID",
        "HapticFeedbackEnvironment",
        "History",
        "HyperTrackEnvironment",
        "ManualVisitsStatus",
        "MapEnvironment",
        "NetworkEnvironment",
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "PasteboardEnvironment",
        "Prelude",
        "PublishableKey",
        "PushEnvironment",
        "PushStatus",
        "RestorationState",
        "SDK",
        "StateRestorationEnvironment",
        "TabSelection",
        "Tagged",
        "Visit"
      ]
    ),
    .target(
      name: "AppLive",
      dependencies: [
        .product(name: "APIEnvironmentLive", package: "APIEnvironment"),
        "App",
        .product(name: "DeepLinkEnvironmentLive", package: "DeepLinkEnvironment"),
        .product(name: "HapticFeedbackEnvironmentLive", package: "HapticFeedbackEnvironment"),
        .product(name: "HyperTrackEnvironmentLive", package: "HyperTrackEnvironment"),
        .product(name: "MapEnvironmentLive", package: "MapEnvironment"),
        .product(name: "NetworkEnvironmentLive", package: "NetworkEnvironment"),
        .product(name: "PasteboardEnvironmentLive", package: "PasteboardEnvironment"),
        .product(name: "PushEnvironmentLive", package: "PushEnvironment"),
        .product(name: "StateRestorationEnvironmentLive", package: "StateRestorationEnvironment")
      ]
    ),
    .testTarget(name: "AppTests", dependencies: ["App"])
  ]
)
