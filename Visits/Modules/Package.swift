// swift-tools-version:5.3

import PackageDescription

let architecture = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let nonEmpty = Target.Dependency.product(name: "NonEmpty", package: "swift-nonempty")

let targets: [Target] = [
  .target(name: "AppArchitecture",                 dependencies: [architecture, "LogEnvironment", "Utility"]),
  .target(name: "Types",                           dependencies: [architecture, nonEmpty, "Utility", "Tagged"]),
  .target(name: "Utility"),
  // Screen
  .target(name: "AppScreen",                       dependencies: [architecture, "BlockerScreen", "DriverIDScreen", "LoadingScreen", "MapScreen", "OrderScreen", "OrdersScreen", "PlacesScreen", "ProfileScreen", "SignInScreen", "SummaryScreen", "Types", "Views"]),
  .target(name: "BlockerScreen",                   dependencies: ["Views"]),
  .target(name: "DriverIDScreen",                  dependencies: [architecture, "Types", "Views"]),
  .target(name: "LoadingScreen"),
  .target(name: "MapScreen",                       dependencies: ["Types"]),
  .target(name: "OrderScreen",                     dependencies: [architecture, nonEmpty, "Types", "Views"]),
  .target(name: "OrdersScreen",                    dependencies: [architecture, "Types", "Views"]),
  .target(name: "PlacesScreen",                    dependencies: [architecture, "Types", "Views"]),
  .target(name: "ProfileScreen",                   dependencies: [nonEmpty, "Types", "Views"]),
  .target(name: "SignInScreen",                    dependencies: ["Types", "Views"]),
  .target(name: "SummaryScreen",                   dependencies: ["Views"]),
  .target(name: "Views"),
  
  // Environment
  .target(name: "AppLive",                         dependencies: ["APIEnvironmentLive", "AppBundleDependencyLive", "AppLogic", "BranchEnvironmentLive", "ErrorReportingEnvironmentLive", "HapticFeedbackEnvironmentLive", "HyperTrackEnvironmentLive", "MapEnvironmentLive", "PasteboardEnvironmentLive", "PushEnvironmentLive", "StateRestorationEnvironmentLive"]),
  .target(name: "APIEnvironment",                  dependencies: [architecture, "Types"]),
  .target(name: "APIEnvironmentLive",              dependencies: ["APIEnvironment", "LogEnvironment", "Tagged", "Types"]),
  .target(name: "AppBundleDependency",             dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "AppBundleDependencyLive",         dependencies: ["AppBundleDependency", "LogEnvironment"]),
  .target(name: "BranchEnvironment",               dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "BranchEnvironmentLive",           dependencies: ["Branch", "BranchEnvironment", "LogEnvironment"]),
  .target(name: "PushEnvironmentLive",             dependencies: ["LogEnvironment", "PushEnvironment"]),
  .target(name: "ErrorReportingEnvironment",       dependencies: [architecture, nonEmpty, "Tagged", "Types"]),
  .target(name: "ErrorReportingEnvironmentLive",   dependencies: ["ErrorReportingEnvironment", "LogEnvironment", "Sentry"]),
  .target(name: "HapticFeedbackEnvironment",       dependencies: [architecture]),
  .target(name: "HapticFeedbackEnvironmentLive",   dependencies: ["HapticFeedbackEnvironment", "LogEnvironment"]),
  .target(name: "HyperTrackEnvironment",           dependencies: [architecture, "Utility", "Types"]),
  .target(name: "HyperTrackEnvironmentLive",       dependencies: ["HyperTrack", "HyperTrackEnvironment", "LogEnvironment", nonEmpty, "Tagged"]),
  .target(name: "LogEnvironment",                  dependencies: [architecture]),
  .target(name: "MapEnvironment",                  dependencies: [architecture, "Utility", "Types"]),
  .target(name: "MapEnvironmentLive",              dependencies: ["LogEnvironment", "MapEnvironment"]),
  .target(name: "PasteboardEnvironment",           dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "PasteboardEnvironmentLive",       dependencies: ["LogEnvironment", "PasteboardEnvironment"]),
  .target(name: "PushEnvironment",                 dependencies: [architecture]),
  .target(name: "StateRestorationEnvironment",     dependencies: [architecture, "Types"]),
  .target(name: "StateRestorationEnvironmentLive", dependencies: ["LogEnvironment", "Utility", "StateRestorationEnvironment", "Types"]),
  // Logic
  .target(name: "AppLogic",                        dependencies: ["APIEnvironment", "AppArchitecture", "AppBundleDependency", "AppStartupLogic", "AppVisibilityLogic", "AppVisibilityStartupLogic", architecture, "AutoSavingLogic", "BlockerLogic", "BranchEnvironment", "ErrorReportingEnvironment", "DeepLinkLogic", "DriverIDLogic", "ErrorAlertLogic", "FirstRunLogic", "HapticFeedbackEnvironment", "HyperTrackEnvironment", "HistoryLogic", "ManualReportLogic", "MapEnvironment", "MapLogic", nonEmpty, "OrdersLogic", "PasteboardEnvironment", "PlacesLogic", "Utility", "PushEnvironment", "RequestLogic", "SignInLogic", "SDKInitializationLogic", "SDKLaunchingLogic", "SDKStatusUpdateLogic", "StateRestorationEnvironment", "StateRestorationLogic", "TabLogic", "Tagged", "TrackingLogic", "Types"]),
  .target(name: "AppStartupLogic",                 dependencies: [architecture]),
  .target(name: "AppVisibilityLogic",              dependencies: [architecture, "Types"]),
  .target(name: "AppVisibilityStartupLogic",       dependencies: [architecture, "Types"]),
  .target(name: "AutoSavingLogic",                 dependencies: [architecture, "Types"]),
  .target(name: "BlockerLogic",                    dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "DeepLinkLogic",                   dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "DriverIDLogic",                   dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "ErrorAlertLogic",                 dependencies: [architecture, "Utility", "Types"]),
  .target(name: "FirstRunLogic",                   dependencies: [architecture, "Types"]),
  .target(name: "HistoryLogic",                    dependencies: [architecture, "Types"]),
  .target(name: "MapLogic",                        dependencies: [architecture, "Types"]),
  .target(name: "ManualReportLogic",               dependencies: [architecture, "Types"]),
  .target(name: "OrderLogic",                      dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "OrdersLogic",                     dependencies: ["AppArchitecture", architecture, nonEmpty, "OrderLogic", "Utility", "Tagged", "Types"]),
  .target(name: "PlacesLogic",                     dependencies: [architecture, "Types"]),
  .target(name: "RequestLogic",                    dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "SignInLogic",                     dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "StateRestorationLogic",           dependencies: ["AppArchitecture", architecture, "Utility", "StateRestorationEnvironment", "Types"]),
  .target(name: "SDKInitializationLogic",          dependencies: [architecture, "Types"]),
  .target(name: "SDKLaunchingLogic",               dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "SDKStatusUpdateLogic",            dependencies: [architecture, "Types"]),
  .target(name: "TabLogic",                        dependencies: [architecture, "Types"]),
  .target(name: "TrackingLogic",                   dependencies: [architecture]),
  // Ties everything together
  .target(name: "AppAdapter",                      dependencies: ["AppLogic", "AppScreen", architecture, "MapScreen", "Utility", "Types"]),
]

let testTargets: [Target] = [
  .testTarget(name: "APIEnvironmentLiveTests",     dependencies: ["APIEnvironmentLive", "Utility"]),
  .testTarget(name: "TypesTests",                  dependencies: ["Types"])
]

let package = Package(
  name: "Modules",
  platforms: [.iOS(.v14)],
  products: [
    .library(name: "App",   targets: ["AppLogic", "AppAdapter", "AppLive", "AppScreen", "AppArchitecture"]),
  ] + targets.map {
    .library(name: $0.name, targets: [$0.name])
  },
  dependencies: [
    .package(name: "Branch",     url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", .exact("1.39.3")),
    .package(                    url: "https://github.com/pointfreeco/swift-composable-architecture",         .exact("0.18.0")),
    .package(name: "HyperTrack", url: "https://github.com/hypertrack/sdk-ios",                                .exact("4.8.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-nonempty",                        .exact("0.3.1")),
    .package(name: "Sentry",     url: "https://github.com/getsentry/sentry-cocoa",                            .exact("5.2.2")),
    .package(name: "Tagged",     url: "https://github.com/pointfreeco/swift-tagged",                          .exact("0.5.0"))
  ],
  targets: targets + testTargets
)
