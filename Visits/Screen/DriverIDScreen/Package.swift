// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "DriverIDScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "DriverIDScreen", targets: ["DriverIDScreen"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.14.0")),
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6"))
  ],
  targets: [
    .target(
      name: "DriverIDScreen",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Views"
      ]
    )
  ]
)
