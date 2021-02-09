// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Visit",
  platforms: [.iOS(.v13)],
  products: [.library(name: "Visit", targets: ["Visit"])],
  dependencies: [
    .package(path: "Coordinate"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.12")),
    .package(name: "Tagged", url: "https://github.com/pointfreeco/swift-tagged", .exact("0.5.0"))
  ],
  targets: [
    .target(
      name: "Visit",
      dependencies: [
        "Coordinate",
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "Prelude",
        "Tagged"
      ]
    )
  ]
)
