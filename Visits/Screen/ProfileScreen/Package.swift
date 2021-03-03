// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "ProfileScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "ProfileScreen", targets: ["ProfileScreen"])],
  dependencies: [
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6"))
  ],
  targets: [
    .target(
      name: "ProfileScreen",
      dependencies: [
        "Views"
      ]
    )
  ]
)
