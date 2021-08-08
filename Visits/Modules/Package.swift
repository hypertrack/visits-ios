// swift-tools-version:5.3

import PackageDescription

let architecture = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let nonEmpty = Target.Dependency.product(name: "NonEmpty", package: "swift-nonempty")
let tagged = Target.Dependency.product(name: "Tagged", package: "swift-tagged")

let targets: [Target] = [
  .target(name: "AppArchitecture",                 dependencies: [architecture, "LogEnvironment", "Utility"]),
  .target(name: "Types",                           dependencies: [architecture, nonEmpty, "Utility", tagged]),
  .target(name: "Utility"),
  // Screen
  .target(name: "AppScreen",                       dependencies: ["AddPlaceView", architecture, "BlockerScreen", "LoadingScreen", "MapScreen", "OrderScreen", "OrdersScreen", "PlacesScreen", "ProfileScreen", "SignInScreen", "SummaryScreen", "Types", "Views"]),
  .target(name: "AddPlaceView",                    dependencies: [architecture, "Types", "Utility", "Views"]),
  .target(name: "BlockerScreen",                   dependencies: ["Views"]),
  .target(name: "LoadingScreen"),
  .target(name: "MapDrawing",                      dependencies: ["Types"]),
  .target(name: "MapScreen",                       dependencies: ["Types", "MapDrawing"]),
  .target(name: "OrderScreen",                     dependencies: [architecture, nonEmpty, "Types", "Views"]),
  .target(name: "OrdersScreen",                    dependencies: [architecture, "Types", "Views"]),
  .target(name: "PlacesScreen",                    dependencies: [architecture, "Types", "Views"]),
  .target(name: "ProfileScreen",                   dependencies: [nonEmpty, "Types", "Utility", "Views"]),
  .target(name: "SignInScreen",                    dependencies: ["Types", "Views"]),
  .target(name: "SummaryScreen",                   dependencies: ["Views"]),
  .target(name: "Views"),
  
  // Environment
  .target(name: "AppLive",                         dependencies: ["APIEnvironmentLive", "AppBundleDependencyLive", "AppLogic", "BranchEnvironmentLive", "ErrorReportingEnvironmentLive", "HapticFeedbackEnvironmentLive", "HyperTrackEnvironmentLive", "MapEnvironmentLive", "PasteboardEnvironmentLive", "PushEnvironmentLive", "StateRestorationEnvironmentLive"]),
  .target(name: "APIEnvironment",                  dependencies: [architecture, "Types"]),
  .target(name: "APIEnvironmentLive",              dependencies: ["APIEnvironment", "LogEnvironment", tagged, "Types", "Utility"]),
  .target(name: "AppBundleDependency",             dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "AppBundleDependencyLive",         dependencies: ["AppBundleDependency", "LogEnvironment"]),
  .target(name: "BranchEnvironment",               dependencies: [architecture, nonEmpty, "Types", "Validated"]),
  .target(name: "BranchEnvironmentLive",           dependencies: ["Branch", "BranchEnvironment", "LogEnvironment", tagged, "Utility", "Validated"]),
  .target(name: "PushEnvironmentLive",             dependencies: ["LogEnvironment", "PushEnvironment"]),
  .target(name: "ErrorReportingEnvironment",       dependencies: [architecture, nonEmpty, tagged, "Types"]),
  .target(name: "ErrorReportingEnvironmentLive",   dependencies: ["ErrorReportingEnvironment", "LogEnvironment", "Sentry"]),
  .target(name: "HapticFeedbackEnvironment",       dependencies: [architecture]),
  .target(name: "HapticFeedbackEnvironmentLive",   dependencies: ["HapticFeedbackEnvironment", "LogEnvironment"]),
  .target(name: "HyperTrackEnvironment",           dependencies: [architecture, "Utility", "Types"]),
  .target(name: "HyperTrackEnvironmentLive",       dependencies: ["HyperTrack", "HyperTrackEnvironment", "LogEnvironment", nonEmpty, tagged]),
  .target(name: "LogEnvironment",                  dependencies: [architecture]),
  .target(name: "MapEnvironment",                  dependencies: [architecture, "Utility", "Types"]),
  .target(name: "MapEnvironmentLive",              dependencies: ["LogEnvironment", "MapEnvironment"]),
  .target(name: "PasteboardEnvironment",           dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "PasteboardEnvironmentLive",       dependencies: ["LogEnvironment", "PasteboardEnvironment"]),
  .target(name: "PushEnvironment",                 dependencies: [architecture]),
  .target(name: "StateRestorationEnvironment",     dependencies: [architecture, "Types"]),
  .target(name: "StateRestorationEnvironmentLive", dependencies: ["LogEnvironment", "Utility", "StateRestorationEnvironment", "Types"]),
  // Logic
  .target(name: "AppLogic",                        dependencies: ["AddPlaceLogic", "APIEnvironment", "AppArchitecture", "AppBundleDependency", "AppStartupLogic", "AppVisibilityLogic", "AppVisibilityStartupLogic", architecture, "AutoSavingLogic", "BlockerLogic", "BranchEnvironment", "ErrorReportingEnvironment", "DeepLinkLogic", "ErrorAlertLogic", "FirstRunLogic", "HapticFeedbackEnvironment", "HyperTrackEnvironment", "HistoryLogic", "IntegrationLogic", "ManualReportLogic", "MapEnvironment", "MapLogic", nonEmpty, "OrdersLogic", "PasteboardEnvironment", "PlacesLogic", "ProfileLogic", "Utility", "PushEnvironment", "RequestLogic", "SignInLogic", "SDKInitializationLogic", "SDKLaunchingLogic", "SDKStatusUpdateLogic", "StateRestorationEnvironment", "StateRestorationLogic", "TabLogic", tagged, "TrackingLogic", "Types"]),
  .target(name: "AddPlaceLogic",                   dependencies: ["AppArchitecture", architecture, "Types", "Utility"]),
  .target(name: "AppStartupLogic",                 dependencies: [architecture, "Types"]),
  .target(name: "AppVisibilityLogic",              dependencies: [architecture, "Types"]),
  .target(name: "AppVisibilityStartupLogic",       dependencies: [architecture, "Types"]),
  .target(name: "AutoSavingLogic",                 dependencies: [architecture, "Types"]),
  .target(name: "BlockerLogic",                    dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "DeepLinkLogic",                   dependencies: ["AppArchitecture", architecture, nonEmpty, "Types", "Utility", "Validated"]),
  .target(name: "ErrorAlertLogic",                 dependencies: [architecture, "Utility", "Types"]),
  .target(name: "FirstRunLogic",                   dependencies: [architecture, "Types"]),
  .target(name: "HistoryLogic",                    dependencies: [architecture, "Types"]),
  .target(name: "IntegrationLogic",                dependencies: [architecture, "Types"]),
  .target(name: "MapLogic",                        dependencies: [architecture, "Types"]),
  .target(name: "ManualReportLogic",               dependencies: [architecture, "Types"]),
  .target(name: "OrderLogic",                      dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "OrdersLogic",                     dependencies: ["AppArchitecture", architecture, nonEmpty, "OrderLogic", "Utility", tagged, "Types"]),
  .target(name: "PlacesLogic",                     dependencies: [architecture, "Types", "Utility"]),
  .target(name: "ProfileLogic",                    dependencies: ["AppArchitecture", "Types"]),
  .target(name: "RequestLogic",                    dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "SignInLogic",                     dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "StateRestorationLogic",           dependencies: ["AppArchitecture", architecture, "Utility", "StateRestorationEnvironment", "Types"]),
  .target(name: "SDKInitializationLogic",          dependencies: [architecture, "Types", "Utility"]),
  .target(name: "SDKLaunchingLogic",               dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "SDKStatusUpdateLogic",            dependencies: [architecture, "Types"]),
  .target(name: "TabLogic",                        dependencies: [architecture, "Types"]),
  .target(name: "TrackingLogic",                   dependencies: [architecture]),
  // Ties everything together
  .target(name: "AppAdapter",                      dependencies: ["AppLogic", "AppScreen", architecture, "MapScreen", "Utility", "Types"]),
]

let testTargets: [Target] = [
  .testTarget(name: "APIEnvironmentLiveTests",     dependencies: ["APIEnvironmentLive", "Utility"]),
  .testTarget(name: "TypesTests",                  dependencies: ["Types"]),
  .testTarget(name: "UtilityTests",                dependencies: ["Utility"])
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
    .package(name: "Branch",     url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", .exact("1.39.4")),
    .package(                    url: "https://github.com/pointfreeco/swift-composable-architecture",         .exact("0.23.0")),
    .package(name: "HyperTrack", url: "https://github.com/hypertrack/sdk-ios",                                .exact("4.8.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-nonempty",                        .exact("0.3.1")),
    .package(name: "Sentry",     url: "https://github.com/getsentry/sentry-cocoa",                            .exact("5.2.2")),
    .package(                    url: "https://github.com/pointfreeco/swift-tagged",                          .exact("0.6.0")),
    .package(name: "Validated",  url: "https://github.com/pointfreeco/swift-validated.git",                   .exact("0.2.1"))
  ],
  targets: targets + testTargets
)
