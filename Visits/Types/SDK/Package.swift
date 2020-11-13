// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "SDK",
  platforms: [.iOS(.v13)],
  products: [.library(name: "SDK", targets: ["SDK"])],
  dependencies: [.package(path: "DeviceID")],
  targets: [.target(name: "SDK", dependencies: ["DeviceID"])]
)
