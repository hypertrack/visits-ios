// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "History",
  platforms: [.iOS(.v13)],
  products: [.library(name: "History", targets: ["History"])],
  dependencies: [.package(path: "Coordinate")],
  targets: [.target(name: "History", dependencies: ["Coordinate"])]
)
