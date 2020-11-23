// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "VisitScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "VisitScreen", targets: ["VisitScreen"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.9.0")),
    .package(path: "Coordinate"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6"))
  ],
  targets: [
    .target(
      name: "VisitScreen",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Coordinate",
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "Views"
      ]
    )
  ]
)
