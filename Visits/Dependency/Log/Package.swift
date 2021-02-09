// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Log",
  platforms: [.iOS(.v13)],
  products: [.library(name: "Log", targets: ["Log"])],
  dependencies: [.package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.13.0"))],
  targets: [.target(name: "Log", dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture")])]
)
