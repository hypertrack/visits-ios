// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "AppAdapter",
  platforms: [.iOS(.v13)],
  products: [.library(name: "AppAdapter", targets: ["AppAdapter"])],
  dependencies: [
    .package(path: "App"),
    .package(path: "AppScreen"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.15.0")),
    .package(path: "Coordinate"),
    .package(path: "DeepLinkScreen"),
    .package(path: "MapScreen"),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.12")),
    .package(path: "PushStatus"),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "AppAdapter",
      dependencies: [
        "App",
        "AppScreen",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Coordinate",
        "DeepLinkScreen",
        "MapScreen",
        "Prelude",
        "PushStatus",
        "Visit"
      ]
    )
  ]
)
