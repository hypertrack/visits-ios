// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Experience",
  platforms: [.iOS(.v13)],
  products: [.library(name: "Experience", targets: ["Experience"])],
  targets: [.target(name: "Experience", dependencies: [])]
)
