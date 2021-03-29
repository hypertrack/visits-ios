// swift-tools-version:5.3

import PackageDescription

let architecture = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let nonEmpty = Target.Dependency.product(name: "NonEmpty", package: "swift-nonempty")

let certificates: [Resource] = [
  .copy("Resources/AmazonRootCA1.cer"),
  .copy("Resources/AmazonRootCA2.cer"),
  .copy("Resources/AmazonRootCA3.cer"),
  .copy("Resources/AmazonRootCA4.cer"),
  .copy("Resources/SFSRootCAG2.cer")
]

let targets: [Target] = [
  .target(name: "AppArchitecture",                 dependencies: [architecture, "LogEnvironment", "Prelude"]),
  // Type
  .target(name: "Types",                           dependencies: [nonEmpty, "Prelude", "Tagged"]),
  // Screen
  .target(name: "AppScreen",                       dependencies: [architecture, "BlockerScreen", "DriverIDScreen", "LoadingScreen", "MapScreen", "OrderScreen", "OrdersScreen", "ProfileScreen", "SignInScreen", "SignUpFormScreen", "SignUpQuestionsScreen", "SignUpVerificationScreen", "SummaryScreen", "Types", "Views"]),
  .target(name: "BlockerScreen",                   dependencies: ["Views"]),
  .target(name: "DriverIDScreen",                  dependencies: [architecture, "Views"]),
  .target(name: "LoadingScreen"),
  .target(name: "MapScreen",                       dependencies: ["Types"]),
  .target(name: "ProfileScreen",                   dependencies: ["Views"]),
  .target(name: "SignInScreen",                    dependencies: ["Views"]),
  .target(name: "SignUpFormScreen",                dependencies: ["Views"]),
  .target(name: "SignUpQuestionsScreen",           dependencies: [nonEmpty, "Prelude", "Tagged", "Types", "Views"]),
  .target(name: "SignUpVerificationScreen",        dependencies: ["Views"]),
  .target(name: "SummaryScreen",                   dependencies: ["Views"]),
  .target(name: "Views"),
  .target(name: "OrderScreen",                     dependencies: [architecture, nonEmpty, "Types", "Views"]),
  .target(name: "OrdersScreen",                    dependencies: [architecture, "Views"]),
  // Environment
  .target(name: "AppLive",                         dependencies: ["APIEnvironmentLive", "AppLogic", "BranchEnvironmentLive", "HapticFeedbackEnvironmentLive", "HyperTrackEnvironmentLive", "MapEnvironmentLive", "NetworkEnvironmentLive", "PasteboardEnvironmentLive", "PushEnvironmentLive", "StateRestorationEnvironmentLive"]),
  .target(name: "APIEnvironment",                  dependencies: [architecture, nonEmpty, "Prelude", "Tagged", "Types"]),
  .target(name: "APIEnvironmentLive",              dependencies: ["APIEnvironment", "LogEnvironment", "Tagged", "Types"], resources: certificates),
  .target(name: "BranchEnvironment",             dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "BranchEnvironmentLive",         dependencies: ["Branch", "BranchEnvironment", "LogEnvironment"]),
  .target(name: "HapticFeedbackEnvironment",       dependencies: [architecture]),
  .target(name: "HapticFeedbackEnvironmentLive",   dependencies: ["HapticFeedbackEnvironment", "LogEnvironment"]),
  .target(name: "HyperTrackEnvironment",           dependencies: [architecture, "Prelude", "Types"]),
  .target(name: "HyperTrackEnvironmentLive",       dependencies: ["HyperTrack", "HyperTrackEnvironment", "LogEnvironment", nonEmpty, "Tagged"]),
  .target(name: "LogEnvironment",                  dependencies: [architecture]),
  .target(name: "MapEnvironment",                  dependencies: [architecture, "Prelude", "Types"]),
  .target(name: "MapEnvironmentLive",              dependencies: ["LogEnvironment", "MapEnvironment"]),
  .target(name: "NetworkEnvironment",              dependencies: [architecture]),
  .target(name: "NetworkEnvironmentLive",          dependencies: ["LogEnvironment", "NetworkEnvironment"]),
  .target(name: "PasteboardEnvironment",           dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "PasteboardEnvironmentLive",       dependencies: ["LogEnvironment", "PasteboardEnvironment"]),
  .target(name: "PushEnvironment",                 dependencies: [architecture]),
  .target(name: "PushEnvironmentLive",             dependencies: ["LogEnvironment", "PushEnvironment"]),
  .target(name: "StateRestorationEnvironment",     dependencies: [architecture, "Types"]),
  .target(name: "StateRestorationEnvironmentLive", dependencies: ["LogEnvironment", "Prelude", "StateRestorationEnvironment", "Types"]),
  // Logic
  .target(name: "AppLogic",                        dependencies: ["APIEnvironment", "AppArchitecture", architecture, "BranchEnvironment", "DeepLinkLogic", "HapticFeedbackEnvironment", "HyperTrackEnvironment", "MapEnvironment", "NetworkEnvironment", nonEmpty, "PasteboardEnvironment", "Prelude", "PushEnvironment", "StateRestorationEnvironment", "Tagged", "Types"]),
  .target(name: "DeepLinkLogic",                   dependencies: [architecture, "AppArchitecture", "Prelude", "Types"]),
  // Ties everything together
  .target(name: "AppAdapter",                      dependencies: ["AppLogic", "AppScreen", architecture, "MapScreen", "Prelude", "SignUpFormScreen", "SignUpQuestionsScreen", "SignUpVerificationScreen", "Types"]),
]

let testTargets: [Target] = [
  .testTarget(name: "APIEnvironmentLiveTests",     dependencies: ["APIEnvironmentLive", "Prelude"]),
  .testTarget(name: "TypesTests",                  dependencies: ["Types"])
]

let package = Package(
  name: "Modules",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "App",   targets: ["AppLogic", "AppAdapter", "AppLive", "AppScreen", "AppArchitecture"]),
  ] + targets.map {
    .library(name: $0.name, targets: [$0.name])
  },
  dependencies: [
    .package(name: "Branch",     url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", .exact("1.38.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-composable-architecture",         .exact("0.16.0")),
    .package(name: "HyperTrack", url: "https://github.com/hypertrack/sdk-ios",                                .exact("4.8.0-rc.1")),
    .package(                    url: "https://github.com/pointfreeco/swift-nonempty",
                                                                                                              .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Prelude",    url: "https://github.com/hypertrack/prelude-swift",                          .exact("0.0.12")),
    .package(name: "Tagged",     url: "https://github.com/pointfreeco/swift-tagged",                          .exact("0.5.0"))
  ],
  targets: targets + testTargets
)
