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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.15.0")),
    .package(path: "BlockerScreen"),
    .package(path: "DeepLinkScreen"),
    .package(path: "DeviceID"),
    .package(path: "DriverID"),
    .package(path: "DriverIDScreen"),
    .package(path: "History"),
    .package(path: "LoadingScreen"),
    .package(path: "MapScreen"),
    .package(path: "ProfileScreen"),
    .package(path: "SignInScreen"),
    .package(path: "SummaryScreen"),
    .package(path: "TabSelection"),
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6")),
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
        "DeviceID",
        "DriverID",
        "DriverIDScreen",
        "History",
        "LoadingScreen",
        "MapScreen",
        "ProfileScreen",
        "SignInScreen",
        "SummaryScreen",
        "TabSelection",
        "Views",
        "VisitScreen",
        "VisitsScreen"
      ]
    )
  ]
)
