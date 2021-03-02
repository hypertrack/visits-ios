// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "SignInScreen",
  platforms: [.iOS(.v13)],
  products: [.library(name: "SignInScreen", targets: ["SignInScreen"])],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.15.0")),
    .package(name: "Views", url: "https://github.com/hypertrack/views-swiftui", .exact("0.0.6"))
  ],
  targets: [
    .target(
      name: "SignInScreen",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Views"
      ]
    )
  ]
)
