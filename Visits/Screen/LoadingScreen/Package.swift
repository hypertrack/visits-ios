// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "LoadingScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "LoadingScreen", targets: ["LoadingScreen"])],
  targets: [.target(name: "LoadingScreen")]
)
