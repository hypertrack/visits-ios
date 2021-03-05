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
    .package(path: "Experience"),
    .package(path: "ManualVisitsStatus"),
    .package(path: "PublishableKey"),
    .package(path: "PushStatus"),
    .package(path: "SDK"),
    .package(path: "TabSelection"),
    .package(path: "Visit")
  ],
  targets: [
    .target(
      name: "RestorationState",
      dependencies: [
        "Credentials",
        "DeviceID",
        "DriverID",
        "Experience",
        "ManualVisitsStatus",
        "PublishableKey",
        "PushStatus",
        "SDK",
        "TabSelection",
        "Visit"
      ]
    )
  ]
)
