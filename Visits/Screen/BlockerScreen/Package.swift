// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "BlockerScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "BlockerScreen", targets: ["BlockerScreen"])],
  dependencies: [
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6"))
  ],
  
  targets: [
    .target(
      name: "BlockerScreen",
      dependencies: [
        "Views"
      ]
    )
  ]
)
