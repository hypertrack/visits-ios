// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "MapScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "MapScreen", targets: ["MapScreen"])],
  dependencies: [.package(path: "Coordinate")],
  targets: [.target(name: "MapScreen", dependencies: ["Coordinate"])]
)
