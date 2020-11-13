// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "LaunchScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "LaunchScreen", targets: ["LaunchScreen"])],
  targets: [.target(name: "LaunchScreen")]
)
