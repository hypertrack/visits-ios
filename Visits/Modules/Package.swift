// swift-tools-version:5.3

import PackageDescription

let architecture = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let nonEmpty = Target.Dependency.product(name: "NonEmpty", package: "swift-nonempty")

let targets: [Target] = [
  .target(name: "AppArchitecture",                 dependencies: [architecture, "LogEnvironment", "Prelude"]),
  // Type
  .target(name: "Coordinate"),
  .target(name: "Credentials",                     dependencies: [nonEmpty, "Tagged"]),
  .target(name: "DeviceID",                        dependencies: [nonEmpty, "Tagged"]),
  .target(name: "DriverID",                        dependencies: [nonEmpty, "Tagged"]),
  .target(name: "Experience"),
  .target(name: "GeoJSON",                         dependencies: ["Coordinate", nonEmpty, "Prelude"]),
  .target(name: "History",                         dependencies: ["Coordinate"]),
  .target(name: "ManualVisitsStatus"),
  .target(name: "PublishableKey",                  dependencies: [nonEmpty, "Tagged"]),
  .target(name: "PushStatus"),
  .target(name: "RestorationState",                dependencies: ["Credentials", "DeviceID", "DriverID", "Experience", "ManualVisitsStatus", "PublishableKey", "PushStatus", "SDK", "TabSelection", "Visit"]),
  .target(name: "SDK",                             dependencies: ["DeviceID"]),
  .target(name: "Types",                           dependencies: [nonEmpty, "Prelude", "Tagged"]),
  .target(name: "TabSelection"),
  .target(name: "Visit",                           dependencies: ["Coordinate", nonEmpty, "Prelude", "Tagged"]),
  // Screen
  .target(name: "AppScreen",                       dependencies: [architecture, "BlockerScreen", "DeepLinkScreen", "DeviceID", "DriverID", "DriverIDScreen", "History", "LoadingScreen", "MapScreen", "ProfileScreen", "SignInScreen", "SignUpFormScreen", "SignUpQuestionsScreen", "SignUpVerificationScreen", "SummaryScreen", "TabSelection", "Views", "VisitScreen", "VisitsScreen"]),
  .target(name: "BlockerScreen",                   dependencies: ["Views"]),
  .target(name: "DeepLinkScreen",                  dependencies: [architecture, "Views"]),
  .target(name: "DriverIDScreen",                  dependencies: [architecture, "Views"]),
  .target(name: "LoadingScreen"),
  .target(name: "MapScreen",                       dependencies: ["Coordinate"]),
  .target(name: "ProfileScreen",                   dependencies: ["Views"]),
  .target(name: "SignInScreen",                    dependencies: ["Views"]),
  .target(name: "SignUpFormScreen",                dependencies: ["Views"]),
  .target(name: "SignUpQuestionsScreen",           dependencies: ["Credentials", nonEmpty, "Prelude", "Tagged", "Types", "Views"]),
  .target(name: "SignUpVerificationScreen",        dependencies: ["Views"]),
  .target(name: "SummaryScreen",                   dependencies: ["Views"]),
  .target(name: "Views"),
  .target(name: "VisitScreen",                     dependencies: [architecture, "Coordinate", nonEmpty, "Views"]),
  .target(name: "VisitsScreen",                    dependencies: [architecture, "Views"]),
  // Environment
  .target(name: "APIEnvironment",                  dependencies: [architecture, "Coordinate", "Credentials", "DeviceID", "History", nonEmpty, "Prelude", "PublishableKey", "Tagged", "Types", "Visit"]),
  .target(name: "APIEnvironmentLive",              dependencies: ["APIEnvironment", "Coordinate", "GeoJSON", "LogEnvironment", "Tagged"]),
  .target(name: "DeepLinkEnvironment",             dependencies: [architecture, "DriverID", "ManualVisitsStatus", nonEmpty, "PublishableKey"]),
  .target(name: "DeepLinkEnvironmentLive",         dependencies: ["Branch", "DeepLinkEnvironment", "LogEnvironment"]),
  .target(name: "HapticFeedbackEnvironment",       dependencies: [architecture]),
  .target(name: "HapticFeedbackEnvironmentLive",   dependencies: ["HapticFeedbackEnvironment", "LogEnvironment"]),
  .target(name: "HyperTrackEnvironment",           dependencies: [architecture, "DeviceID", "DriverID", "Prelude", "PublishableKey", "SDK", "Visit"]),
  .target(name: "HyperTrackEnvironmentLive",       dependencies: ["HyperTrack", "HyperTrackEnvironment", "LogEnvironment", nonEmpty, "Tagged"]),
  .target(name: "LogEnvironment",                  dependencies: [architecture]),
  .target(name: "MapEnvironment",                  dependencies: [architecture, "Coordinate", "Prelude", "Visit"]),
  .target(name: "MapEnvironmentLive",              dependencies: ["LogEnvironment", "MapEnvironment"]),
  .target(name: "NetworkEnvironment",              dependencies: [architecture]),
  .target(name: "NetworkEnvironmentLive",          dependencies: ["LogEnvironment", "NetworkEnvironment"]),
  .target(name: "PasteboardEnvironment",           dependencies: [architecture, "Credentials", nonEmpty]),
  .target(name: "PasteboardEnvironmentLive",       dependencies: ["LogEnvironment", "PasteboardEnvironment"]),
  .target(name: "PushEnvironment",                 dependencies: [architecture]),
  .target(name: "PushEnvironmentLive",             dependencies: ["LogEnvironment", "PushEnvironment"]),
  .target(name: "StateRestorationEnvironment",     dependencies: [architecture, "RestorationState"]),
  .target(name: "StateRestorationEnvironmentLive", dependencies: ["Credentials", "DriverID", "LogEnvironment", "ManualVisitsStatus", "Prelude", "PublishableKey", "PushStatus", "StateRestorationEnvironment", "TabSelection", "Visit"]),
  // Logic
  .target(name: "AppLogic",                        dependencies: ["APIEnvironment", "AppArchitecture", architecture, "Credentials", "DeepLinkEnvironment", "DeviceID", "DriverID", "Experience", "HapticFeedbackEnvironment", "History", "HyperTrackEnvironment", "ManualVisitsStatus", "MapEnvironment", "NetworkEnvironment", nonEmpty, "PasteboardEnvironment", "Prelude", "PublishableKey", "PushEnvironment", "PushStatus", "RestorationState", "SDK", "StateRestorationEnvironment", "TabSelection", "Tagged", "Types", "Visit"]),
  .target(name: "AppLive",                         dependencies: ["APIEnvironmentLive", "AppLogic", "DeepLinkEnvironmentLive", "HapticFeedbackEnvironmentLive", "HyperTrackEnvironmentLive", "MapEnvironmentLive", "NetworkEnvironmentLive", "PasteboardEnvironmentLive", "PushEnvironmentLive", "StateRestorationEnvironmentLive"]),
  .target(name: "AppAdapter",                      dependencies: ["AppLogic", "AppScreen", architecture, "Coordinate", "Credentials", "DeepLinkScreen", "MapScreen", "Prelude", "PushStatus", "SignUpFormScreen", "SignUpQuestionsScreen", "SignUpVerificationScreen", "Visit"]),
]

let testTargets: [Target] = [
  .testTarget(name: "APIEnvironmentLiveTests",     dependencies: ["APIEnvironmentLive"]),
  .testTarget(name: "GeoJSONTests",                dependencies: ["GeoJSON"])
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
    .package(name: "HyperTrack", url: "https://github.com/hypertrack/sdk-ios",                                .exact("4.7.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-nonempty",
                                                                                                              .revision("b4f37767336e4bb98bffa3e05fad579d91c2b2d4")),
    .package(name: "Prelude",    url: "https://github.com/hypertrack/prelude-swift",                          .exact("0.0.12")),
    .package(name: "Tagged",     url: "https://github.com/pointfreeco/swift-tagged",                          .exact("0.5.0"))
  ],
  targets: targets + testTargets
)


