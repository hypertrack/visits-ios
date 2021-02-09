// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "GeoJSON",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "GeoJSON",
      targets: ["GeoJSON"]
    )
  ],
  dependencies: [
    .package(path: "Coordinate"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Prelude", url: "https://github.com/hypertrack/prelude-swift", .exact("0.0.12"))
  ],
  targets: [
    .target(
      name: "GeoJSON",
      dependencies: [
        "Coordinate",
        .product(name: "NonEmpty", package: "swift-nonempty"),
        "Prelude"
      ]
    ),
    .testTarget(
      name: "GeoJSONTests",
      dependencies: ["GeoJSON"]
    )
  ]
)
