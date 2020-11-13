// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "ManualVisitsStatus",
  platforms: [.iOS(.v13)],
  products: [.library(name: "ManualVisitsStatus", targets: ["ManualVisitsStatus"])],
  targets: [.target(name: "ManualVisitsStatus")]
)
