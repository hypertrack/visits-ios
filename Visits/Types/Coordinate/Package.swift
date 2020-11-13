// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Coordinate",
  platforms: [.iOS(.v13)],
  products: [.library(name: "Coordinate", targets: ["Coordinate"])],
  targets: [.target(name: "Coordinate")]
)
