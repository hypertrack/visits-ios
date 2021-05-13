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
  .target(name: "Types",                           dependencies: [architecture, nonEmpty, "Prelude", "Tagged"]),
  // Screen
  .target(name: "AppScreen",                       dependencies: [architecture, "BlockerScreen", "DriverIDScreen", "LoadingScreen", "MapScreen", "OrderScreen", "OrdersScreen", "PlacesScreen", "ProfileScreen", "SignInScreen", "SignUpFormScreen", "SignUpQuestionsScreen", "SignUpVerificationScreen", "SummaryScreen", "Types", "Views"]),
  .target(name: "BlockerScreen",                   dependencies: ["Views"]),
  .target(name: "DriverIDScreen",                  dependencies: [architecture, "Types", "Views"]),
  .target(name: "LoadingScreen"),
  .target(name: "MapScreen",                       dependencies: ["Types"]),
  .target(name: "OrderScreen",                     dependencies: [architecture, nonEmpty, "Types", "Views"]),
  .target(name: "OrdersScreen",                    dependencies: [architecture, "Types", "Views"]),
  .target(name: "PlacesScreen",                    dependencies: [architecture, "Types", "Views"]),
  .target(name: "ProfileScreen",                   dependencies: [nonEmpty, "Types", "Views"]),
  .target(name: "SignInScreen",                    dependencies: ["Types", "Views"]),
  .target(name: "SignUpFormScreen",                dependencies: ["Types", "Views"]),
  .target(name: "SignUpQuestionsScreen",           dependencies: [nonEmpty, "Prelude", "Tagged", "Types", "Views"]),
  .target(name: "SignUpVerificationScreen",        dependencies: ["Types", "Views"]),
  .target(name: "SummaryScreen",                   dependencies: ["Views"]),
  .target(name: "Views"),
  
  // Environment
  .target(name: "AppLive",                         dependencies: ["APIEnvironmentLive", "AppBundleDependencyLive", "AppLogic", "BranchEnvironmentLive", "ErrorReportingEnvironmentLive", "HapticFeedbackEnvironmentLive", "HyperTrackEnvironmentLive", "MapEnvironmentLive", "NetworkEnvironmentLive", "PasteboardEnvironmentLive", "PushEnvironmentLive", "StateRestorationEnvironmentLive"]),
  .target(name: "APIEnvironment",                  dependencies: [architecture, "Types"]),
  .target(name: "APIEnvironmentLive",              dependencies: ["APIEnvironment", "LogEnvironment", "Tagged", "Types"], resources: certificates),
  .target(name: "AppBundleDependency",             dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "AppBundleDependencyLive",         dependencies: ["AppBundleDependency", "LogEnvironment"]),
  .target(name: "BranchEnvironment",               dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "BranchEnvironmentLive",           dependencies: ["Branch", "BranchEnvironment", "LogEnvironment"]),
  .target(name: "PushEnvironmentLive",             dependencies: ["LogEnvironment", "PushEnvironment"]),
  .target(name: "ErrorReportingEnvironment",       dependencies: [architecture, nonEmpty, "Tagged", "Types"]),
  .target(name: "ErrorReportingEnvironmentLive",   dependencies: ["ErrorReportingEnvironment", "LogEnvironment", "Sentry"]),
  .target(name: "HapticFeedbackEnvironment",       dependencies: [architecture]),
  .target(name: "HapticFeedbackEnvironmentLive",   dependencies: ["HapticFeedbackEnvironment", "LogEnvironment"]),
  .target(name: "HyperTrackEnvironment",           dependencies: [architecture, "Prelude", "Types"]),
  .target(name: "HyperTrackEnvironmentLive",       dependencies: ["HyperTrack", "HyperTrackEnvironment", "LogEnvironment", nonEmpty, "Tagged"]),
  .target(name: "LogEnvironment",                  dependencies: [architecture]),
  .target(name: "MapEnvironment",                  dependencies: [architecture, "Prelude", "Types"]),
  .target(name: "MapEnvironmentLive",              dependencies: ["LogEnvironment", "MapEnvironment"]),
  .target(name: "NetworkEnvironment",              dependencies: [architecture, "Types"]),
  .target(name: "NetworkEnvironmentLive",          dependencies: ["LogEnvironment", "NetworkEnvironment", "Types"]),
  .target(name: "PasteboardEnvironment",           dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "PasteboardEnvironmentLive",       dependencies: ["LogEnvironment", "PasteboardEnvironment"]),
  .target(name: "PushEnvironment",                 dependencies: [architecture]),
  .target(name: "StateRestorationEnvironment",     dependencies: [architecture, "Types"]),
  .target(name: "StateRestorationEnvironmentLive", dependencies: ["LogEnvironment", "Prelude", "StateRestorationEnvironment", "Types"]),
  // Logic
  .target(name: "AppLogic",                        dependencies: ["APIEnvironment", "AppArchitecture", "AppBundleDependency", "AppStartupLogic", architecture, "AutoSavingLogic", "BlockerLogic", "BranchEnvironment", "ErrorReportingEnvironment", "DeepLinkLogic", "DriverIDLogic", "ErrorAlertLogic", "FirstRunLogic", "HapticFeedbackEnvironment", "HyperTrackEnvironment", "HistoryLogic", "ManualReportLogic", "MapEnvironment", "NetworkEnvironment", nonEmpty, "OrdersLogic", "PasteboardEnvironment", "PlacesLogic", "Prelude", "PushEnvironment", "RefreshingLogic", "SignInLogic", "SignUpLogic", "SignUpSignInToggleLogic", "SDKInitializationLogic", "SDKLaunchingLogic", "SDKStatusUpdateLogic", "StateRestorationEnvironment", "StateRestorationLogic", "TabLogic", "Tagged", "TrackingLogic", "Types"]),
  .target(name: "AppStartupLogic",                 dependencies: [architecture]),
  .target(name: "AutoSavingLogic",                 dependencies: [architecture, "Types"]),
  .target(name: "BlockerLogic",                    dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "DeepLinkLogic",                   dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "DriverIDLogic",                   dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "ErrorAlertLogic",                 dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "FirstRunLogic",                   dependencies: [architecture, "Types"]),
  .target(name: "HistoryLogic",                    dependencies: [architecture, "Types"]),
  .target(name: "ManualReportLogic",               dependencies: [architecture, "Types"]),
  .target(name: "OrderLogic",                      dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "OrdersLogic",                     dependencies: ["AppArchitecture", architecture, nonEmpty, "OrderLogic", "Prelude", "Tagged", "Types"]),
  .target(name: "PlacesLogic",                     dependencies: [architecture, "Types"]),
  .target(name: "RefreshingLogic",                 dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "SignInLogic",                     dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "SignUpLogic",                     dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "SignUpSignInToggleLogic",         dependencies: [architecture, "Types"]),
  .target(name: "StateRestorationLogic",           dependencies: ["AppArchitecture", architecture, "Prelude", "StateRestorationEnvironment", "Types"]),
  .target(name: "SDKInitializationLogic",          dependencies: [architecture, "Types"]),
  .target(name: "SDKLaunchingLogic",               dependencies: ["AppArchitecture", architecture, "Prelude", "Types"]),
  .target(name: "SDKStatusUpdateLogic",            dependencies: [architecture, "Types"]),
  .target(name: "TabLogic",                        dependencies: [architecture, "Types"]),
  .target(name: "TrackingLogic",                   dependencies: [architecture]),
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
    .package(name: "Branch",     url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", .exact("1.39.2")),
    .package(                    url: "https://github.com/pointfreeco/swift-composable-architecture",         .exact("0.16.0")),
    .package(name: "HyperTrack", url: "https://github.com/hypertrack/sdk-ios",                                .exact("4.8.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-nonempty",
                                                                                                              .exact("0.3.1")),
    .package(name: "Prelude",    url: "https://github.com/hypertrack/prelude-swift",                          .exact("0.0.12")),
    .package(name: "Sentry",     url: "https://github.com/getsentry/sentry-cocoa",                            .exact("5.2.2")),
    .package(name: "Tagged",     url: "https://github.com/pointfreeco/swift-tagged",                          .exact("0.5.0"))
  ],
  targets: targets + testTargets
)
