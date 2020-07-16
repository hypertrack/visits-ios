import SwiftUI
import CoreLocation
import CoreMotion

import ComposableArchitecture
import Prelude

import App
import Deeplink
import DeeplinkLive
import Deliveries
import Delivery
import Location
import LocationLive
import Motion
import MotionLive
import Notification
import NotificationLive
import Reachability
import ReachabilityLive
import Restoration
import RestorationLive
import SignIn
import Tracking
import TrackingLive
import Branch

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // Handle launch through opening deeplink
    for activity in connectionOptions.userActivities {
      if activity.webpageURL != nil {
        Branch.getInstance().continue(activity)
        break
      }
    }
    
    let appView = AppView(
      store: Store<AppState, AppAction>(
        initialState: .initialState(
          locationPermissions: currentLocationPermissions(),
          motionPermissions: currentMotionPermissions(),
          restoration: restorePreviousState()),
        reducer: appReducer.notifyWhenBecomesTrackable,
        environment: SystemEnvironment.live(environment:
          (
            DeeplinkEnvironment.live,
            Deliveries.live,
            LocationEnvironment.live,
            MotionEnvironment.live,
            NotificationEnvironment.live,
            ReachabilityEnvironment.live,
            RestorationEnvironment.live,
            SignIn.live,
            TrackingEnvironment.live,
            Delivery.live
          )
        )
      )
    )
    
    if let windowScene = scene as? UIWindowScene {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: appView)
        self.window = window
        window.makeKeyAndVisible()
    }
  }
  
  func scene(_: UIScene, continue userActivity: NSUserActivity) {
    Branch.getInstance().continue(userActivity)
  }
}

// MARK: - Initial state helpers

public func currentLocationPermissions() -> LocationPermissions {
  if CLLocationManager.locationServicesEnabled() {
    switch CLLocationManager.authorizationStatus() {
    case .notDetermined:
      return .notRequested
    case .restricted:
      return .restricted
    case .denied:
      return .denied
    case .authorizedAlways, .authorizedWhenInUse:
      return .granted
    @unknown default:
      fatalError()
    }
  } else {
    return .disabled
  }
}

public func currentMotionPermissions() -> MotionState {
  switch CMMotionActivityManager.authorizationStatus() {
  case .notDetermined:
    return .starting(.notDetermined)
  case .restricted:
    return .starting(.restricted)
  case .denied:
    return .final(.denied)
  case .authorized:
    return .starting(.authorized)
  @unknown default:
    fatalError()
  }
}

public func restorePreviousState() -> Restoration {
  let userDefaults = UserDefaults.standard
  let publishableKey = userDefaults.string(forKey: RestorationKey.publishableKey)
    .flatMap(NonEmptyString.init(rawValue:))
  let driverID = userDefaults.string(forKey: RestorationKey.driverID)
    .flatMap(NonEmptyString.init(rawValue:))
  let completedDeliveries = userDefaults
    .array(forKey: RestorationKey.completedDeliveriesIDs)?
    .compactMap { $0 as? String }
    .compactMap { NonEmptyString(rawValue: $0) } ?? []
  switch (publishableKey, driverID) {
  case let (.some(pk), .some(driverID)):
    return .user(publishableKey: pk, driverID: driverID, completedDeliveries: completedDeliveries)
  case let (.some(pk), _):
    return .publishableKey(pk)
  case (.none, _):
    return .failed
  }
}
// { NonEmptyString(rawValue: $0) }
#if DEBUG
public func resetAppState() {
  let userDefaults = UserDefaults.standard
  userDefaults.removeObject(forKey: RestorationKey.driverID)
  userDefaults.removeObject(forKey: RestorationKey.publishableKey)
}
#endif

enum RestorationKey {
  static let completedDeliveriesIDs = "FKvsz7tEs4"
  static let publishableKey = "UeiDZRFEOd"
  static let driverID = "Hp6XdOsXsw"
}
