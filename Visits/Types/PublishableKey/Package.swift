// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "PublishableKey",
  platforms: [.iOS(.v13)],
  products: [.library(name: "PublishableKey", targets: ["PublishableKey"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Tagged", url: "https://github.com/pointfreeco/swift-tagged", .exact("0.5.0"))
  ],
  targets: [
    .target(
      name: "PublishableKey",
      dependencies: [
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "Tagged"
      ]
    )
  ]
)
