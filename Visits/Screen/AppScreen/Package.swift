// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "AppScreen",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "AppScreen",
      targets: ["AppScreen"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.9.0")),
    .package(path: "BlockerScreen"),
    .package(path: "DeepLinkScreen"),
    .package(path: "DriverIDScreen"),
    .package(path: "LoadingScreen"),
    .package(path: "SignInScreen"),
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.5")),
    .package(path: "VisitScreen"),
    .package(path: "VisitsScreen"),
  ],
  targets: [
    .target(
      name: "AppScreen",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "BlockerScreen",
        "DeepLinkScreen",
        "DriverIDScreen",
        "LoadingScreen",
        "SignInScreen",
        "Views",
        "VisitScreen",
        "VisitsScreen"
      ]
    )
  ]
)
