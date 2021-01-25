// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Architecture",
  platforms: [.iOS(.v13)],
  products: [.library(name: "Architecture", targets: ["Architecture"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.11.0")),
    .package(path: "Log"),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.11"))
  ],
  targets: [
    .target(
      name: "Architecture",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Log",
        "Prelude"
      ]
    )
  ]
)
