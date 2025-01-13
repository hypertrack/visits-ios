// swift-tools-version:5.3

import PackageDescription

let architecture = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let customDump = Target.Dependency.product(name: "CustomDump", package: "swift-custom-dump")
let nonEmpty = Target.Dependency.product(name: "NonEmpty", package: "swift-nonempty")
let tagged = Target.Dependency.product(name: "Tagged", package: "swift-tagged")
let orderedCollections = Target.Dependency.product(name: "OrderedCollections", package: "swift-collections")

let targets: [Target] = [
  .target(name: "AppArchitecture",                 dependencies: [architecture, "LogEnvironment", "Utility"]),
  .target(name: "Types",                           dependencies: [architecture, nonEmpty, "Utility", tagged]),
  .target(name: "Utility",                         dependencies: [architecture]),
  // Screen
  .target(name: "AppScreen",                       dependencies: ["AddPlaceView", architecture, "BlockerScreen", "LoadingScreen", "MapScreen", "OrderScreen", "OrdersListScreen", "TripScreen", "PlacesScreen", "ProfileScreen", "SignInScreen", "SummaryScreen", "Types", "Views", "VisitsScreen", "TeamScreen"]),
  .target(name: "AddPlaceView",                    dependencies: [architecture, "MapDetailView", "MapDrawing", "Types", "Utility", "Views"]),
  .target(name: "BlockerScreen",                   dependencies: ["Views"]),
  .target(name: "LoadingScreen"),
  .target(name: "MapDetailView",                   dependencies: ["MapDrawing", "Types"]),
  .target(name: "MapDrawing",                      dependencies: ["Types"]),
  .target(name: "MapScreen",                       dependencies: ["Types", "MapDrawing"]),
  .target(name: "OrderScreen",                     dependencies: [architecture, "MapDetailView", nonEmpty, "Types", "Views"]),
  .target(name: "OrdersListScreen",                dependencies: [architecture, "OrderScreen", "Types", "Views"]),
  .target(name: "TripScreen",                      dependencies: [architecture, "OrdersListScreen", "OrderScreen", "Types", "Views", nonEmpty]),
  .target(name: "PlacesScreen",                    dependencies: [architecture, "MapDetailView", "Types", "Views"]),
  .target(name: "ProfileScreen",                   dependencies: [nonEmpty, "Types", "Utility", "Views"]),
  .target(name: "SignInScreen",                    dependencies: ["Types", "Views"]),
  .target(name: "SummaryScreen",                   dependencies: ["Views"]),
  .target(name: "Views"),
  .target(name: "VisitsScreen",                    dependencies: [architecture, "MapDetailView", "Types", "Views", "PlacesScreen", "Utility"]),
  .target(name: "TeamScreen",                      dependencies: [architecture, "MapDetailView", "Types", "Utility", "Views", "VisitsScreen"]),
  
  // Environment
  .target(name: "AppLive",                         dependencies: ["APIEnvironmentLive", "AppBundleDependencyLive", "AppLogic", "BranchEnvironmentLive", "ErrorReportingEnvironmentLive", "HapticFeedbackEnvironmentLive", "HyperTrackEnvironmentLive", "MapDependencyLive", "PasteboardEnvironmentLive", "PushEnvironmentLive", "StateRestorationEnvironmentLive"]),
  .target(name: "APIEnvironment",                  dependencies: [architecture, "Types"]),
  .target(name: "APIEnvironmentLive",              dependencies: ["APIEnvironment", "LogEnvironment", tagged, "Types", "Utility", "PlacesScreen"]),
  .target(name: "AppBundleDependency",             dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "AppBundleDependencyLive",         dependencies: ["AppBundleDependency", "LogEnvironment"]),
  .target(name: "BranchEnvironment",               dependencies: [architecture, nonEmpty, "Types", "Validated"]),
  .target(name: "BranchEnvironmentLive",           dependencies: ["BranchSDK", "BranchEnvironment", "LogEnvironment", tagged, "Utility", "Validated"]),
  .target(name: "PushEnvironmentLive",             dependencies: ["LogEnvironment", "PushEnvironment"]),
  .target(name: "ErrorReportingEnvironment",       dependencies: [architecture, nonEmpty, tagged, "Types"]),
  .target(name: "ErrorReportingEnvironmentLive",   dependencies: ["ErrorReportingEnvironment", "LogEnvironment", "Sentry"]),
  .target(name: "HapticFeedbackEnvironment",       dependencies: [architecture]),
  .target(name: "HapticFeedbackEnvironmentLive",   dependencies: ["HapticFeedbackEnvironment", "LogEnvironment"]),
  .target(name: "HyperTrackEnvironment",           dependencies: [architecture, "Utility", "Types"]),
  .target(name: "HyperTrackEnvironmentLive",       dependencies: ["HyperTrack", "HyperTrackEnvironment", "LogEnvironment", nonEmpty, tagged, "Utility"]),
  .target(name: "LogEnvironment",                  dependencies: [architecture]),
  .target(name: "MapDependency",                   dependencies: [architecture, "Utility", "Types"]),
  .target(name: "MapDependencyLive",               dependencies: ["LogEnvironment", "MapDependency", orderedCollections]),
  .target(name: "PasteboardEnvironment",           dependencies: [architecture, nonEmpty, "Types"]),
  .target(name: "PasteboardEnvironmentLive",       dependencies: ["LogEnvironment", "PasteboardEnvironment"]),
  .target(name: "PushEnvironment",                 dependencies: [architecture]),
  .target(name: "StateRestorationEnvironment",     dependencies: [architecture, customDump, "Types"]),
  .target(name: "StateRestorationEnvironmentLive", dependencies: ["LogEnvironment", "Utility", "StateRestorationEnvironment", "Types"]),
  // Logic
  .target(name: "AppLogic",                        dependencies: ["AddPlaceLogic", "APIEnvironment", "AppArchitecture", "AppBundleDependency", "AppStartupLogic", customDump, "AppVisibilityLogic", "AppVisibilityStartupLogic", architecture, "AutoSavingLogic", "BlockerLogic", "BranchEnvironment", "ErrorReportingEnvironment", "DeepLinkLogic", "ErrorAlertLogic", "FirstRunLogic", "HapticFeedbackEnvironment", "HyperTrackEnvironment", "HistoryLogic", "IntegrationLogic", "ManualReportLogic", "MapDependency", "MapLogic", nonEmpty, "TripLogic", "PasteboardEnvironment", "PlacesLogic", "VisitsLogic", "ProfileLogic", "Utility", "PushEnvironment", "RequestLogic", "SignInLogic", "SDKInitializationLogic", "SDKLaunchingLogic", "SDKStatusUpdateLogic", "StateRestorationEnvironment", "StateRestorationLogic", "TabLogic", tagged, "TrackingLogic", "Types", "TeamLogic"]),
  .target(name: "AddPlaceLogic",                   dependencies: ["AppArchitecture", architecture, "Types", "Utility"]),
  .target(name: "AppStartupLogic",                 dependencies: [architecture, "Types"]),
  .target(name: "AppVisibilityLogic",              dependencies: [architecture, "Types"]),
  .target(name: "AppVisibilityStartupLogic",       dependencies: [architecture, "Types"]),
  .target(name: "AutoSavingLogic",                 dependencies: [architecture, "Types"]),
  .target(name: "BlockerLogic",                    dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "DeepLinkLogic",                   dependencies: ["AppArchitecture", architecture, nonEmpty, "Types", "Utility", "Validated"]),
  .target(name: "ErrorAlertLogic",                 dependencies: [architecture, nonEmpty, "Utility", "Types"]),
  .target(name: "FirstRunLogic",                   dependencies: [architecture, "Types"]),
  .target(name: "HistoryLogic",                    dependencies: [architecture, "Types"]),
  .target(name: "IntegrationLogic",                dependencies: [architecture, "Types"]),
  .target(name: "MapLogic",                        dependencies: [architecture, "MapDependency", "Types"]),
  .target(name: "ManualReportLogic",               dependencies: [architecture, "Types"]),
  .target(name: "OrderLogic",                      dependencies: ["AppArchitecture", architecture, "Utility", "Types"]),
  .target(name: "TripLogic",                       dependencies: ["AppArchitecture", architecture, nonEmpty, "OrderLogic", "Utility", tagged, "Types"]),
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
  .target(name: "VisitsLogic",                     dependencies: [architecture, "Types", "Utility"]),
  .target(name: "TeamLogic",                       dependencies: [architecture, "Types", "VisitsLogic"]),
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
    .package(name: "BranchSDK",  url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", .exact("3.0.1")),
    .package(                    url: "https://github.com/apple/swift-collections",                           .exact("1.0.6")),
    .package(                    url: "https://github.com/pointfreeco/swift-composable-architecture",         .exact("0.36.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-custom-dump",                     .exact("0.11.2")),
    .package(name: "HyperTrack", url: "https://github.com/hypertrack/sdk-ios",                                .exact("5.8.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-nonempty",                        .exact("0.4.0")),
    .package(name: "Sentry",     url: "https://github.com/getsentry/sentry-cocoa",                            .exact("8.35.0")),
    .package(                    url: "https://github.com/pointfreeco/swift-tagged",                          .exact("0.10.0")),
    .package(name: "Validated",  url: "https://github.com/pointfreeco/swift-validated",                       .exact("0.2.1"))
  ],
  targets: targets + testTargets
)
