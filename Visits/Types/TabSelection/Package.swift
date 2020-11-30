// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "TabSelection",
  platforms: [.iOS(.v13)],
  products: [.library(name: "TabSelection", targets: ["TabSelection"])],
  targets: [.target(name: "TabSelection", dependencies: [])]
)
