// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "RestorationState",
  platforms: [.iOS(.v13)],
  products: [.library(name: "RestorationState", targets: ["RestorationState"])],
  dependencies: [
    .package(path: "Credentials"),
    .package(path: "DeviceID"),
    .package(path: "DriverID"),
    .package(path: "ManualVisitsStatus"),
    .package(path: "PublishableKey"),
    .package(path: "SDK"),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "RestorationState",
      dependencies: [
        "Credentials",
        "DeviceID",
        "DriverID",
        "ManualVisitsStatus",
        "PublishableKey",
        "SDK",
        "Visit"
      ]
    )
  ]
)
