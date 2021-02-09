// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "VisitsScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "VisitsScreen", targets: ["VisitsScreen"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.13.0")),
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6"))
  ],
  targets: [
    .target(
      name: "VisitsScreen",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Views"
      ]
    )
  ]
)
