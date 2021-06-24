import Combine
import ComposableArchitecture
import CoreLocation
import CoreMotion
import HyperTrack
import HyperTrackEnvironment
import LogEnvironment
import NonEmpty
import Types

extension String: Error {}

public extension HyperTrackEnvironment {
  static let live = Self(
    checkDeviceTrackability: {
      Effect.result {
        logEffect("checkDeviceTrackability")
        return .success(servicesAvailability())
      }
    },
    didFailToRegisterForRemoteNotificationsWithError: { error in
      .fireAndForget {
        logEffect("didFailToRegisterForRemoteNotificationsWithError: \(error)")
        HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error)
      }
    },
    didReceiveRemoteNotification: { userInfo, callback in
      .fireAndForget {
        logEffect("didReceiveRemoteNotification: \(userInfo)")
        HyperTrack.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: callback)
      }
    },
    didRegisterForRemoteNotificationsWithDeviceToken: { deviceToken in
      .fireAndForget {
        logEffect("didRegisterForRemoteNotificationsWithDeviceToken")
        HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
      }
    },
    makeSDK: { pk in
      Effect.result {
        logEffect("makeSDK: \(pk.string)")
        ht = try! HyperTrack(publishableKey: HyperTrack.PublishableKey(pk.string)!)
        return .success(statusUpdate())
      }
    },
    openSettings: {
      .fireAndForget {
        logEffect("openSettings")
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
      }
    },
    registerForRemoteNotifications: {
      .fireAndForget {
        logEffect("registerForRemoteNotifications")
        HyperTrack.registerForRemoteNotifications()
      }
    },
    requestAlwaysLocationPermissions: {
      .fireAndForget {
        logEffect("requestLocationPermissions")
        lm.requestAlwaysAuthorization()
      }
    },
    requestWhenInUseLocationPermissions: {
      .fireAndForget {
        logEffect("requestLocationPermissions")
        lm.requestWhenInUseAuthorization()
      }
    },
    requestMotionPermissions: {
      Effect.future { callback in
        logEffect("requestMotionPermissions")
        mm.queryActivityStarting(
          from: Date(),
          to: Date(),
          to: .main) { _, _ in
          callback(.success(statusUpdate()))
        }
      }
    },
    setDriverID: { drID in
      .fireAndForget {
        logEffect("setDriverID: \(drID.string)")
        if let ht = ht {
          ht.setDeviceMetadata(
            HyperTrack.Metadata(
              dictionary: [C.driverID.rawValue: drID.string]
            )!
          )
          if drID.string.contains("@") {
            let name = String(drID.string.prefix(while: { $0 != "@" })).capitalizingFirstLetter()
            ht.setDeviceName(name)
          } else {
            ht.setDeviceName(drID.string)
          }
        }
      }
    },
    startTracking: {
      .fireAndForget {
        logEffect("startTracking")
        ht?.start()
      }
    },
    stopTracking: {
      .fireAndForget {
        logEffect("stopTracking")
        ht?.stop()
      }
    },
    subscribeToStatusUpdates: {
      Effect.run { subscriber in
        logEffect("subscribeToStatusUpdates")
        lmd = LocationManagerClientDelegate { subscriber.send(statusUpdate()) }
        
        NotificationCenter.default
          .publisher(for: UIScene.willEnterForegroundNotification)
          .merge(
            with:
              NotificationCenter.default
              .publisher(for: HyperTrack.startedTrackingNotification),
            NotificationCenter.default
              .publisher(for: HyperTrack.stoppedTrackingNotification)
          )
          .sink { _ in subscriber.send(statusUpdate()) }
          .store(in: &cancellables)
        
        NotificationCenter.default
          .publisher(for: HyperTrack.didEncounterRestorableErrorNotification)
          .compactMap { $0.hyperTrackRestorableError() }
          .drop(while: { $0 != .trialEnded })
          .sink { _ in subscriber.send(statusUpdate(.deleted)) }
          .store(in: &cancellables)
        
        NotificationCenter.default
          .publisher(for: HyperTrack.didEncounterUnrestorableErrorNotification)
          .compactMap { $0.hyperTrackUnrestorableError() }
          .drop(while: { $0 != .invalidPublishableKey })
          .sink { _ in subscriber.send(statusUpdate(.invalidPublishableKey)) }
          .store(in: &cancellables)
        
        return AnyCancellable {
          lmd = nil
          cancellables = []
        }
      }
    },
    syncDeviceSettings: {
      .fireAndForget {
        logEffect("syncDeviceSettings")
        ht?.syncDeviceSettings()
      }
    }
  )
}

enum C: String {
  case driverID = "driver_id"
}

var ht: HyperTrack?

let lm = CLLocationManager()
var lmd: LocationManagerClientDelegate?

let mm = CMMotionActivityManager()

var cancellables: Set<AnyCancellable> = []

class LocationManagerClientDelegate: NSObject, CLLocationManagerDelegate {
  let didChangeAuthorization: () -> Void
  
  init(didChangeAuthorization: @escaping () -> Void) {
    self.didChangeAuthorization = didChangeAuthorization
    super.init()
    lm.delegate = self
  }
  
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    self.didChangeAuthorization()
  }
}

func locationAccuracy() -> LocationAccuracy {
  switch lm.accuracyAuthorization {
  case .fullAccuracy:    return .full
  case .reducedAccuracy: return .reduced
  @unknown default:      return .reduced
  }
}

func locationPermissions() -> LocationPermissions {
  let locationPermissions: LocationPermissions
  
  switch lm.authorizationStatus {
  case .notDetermined:
    locationPermissions = .notDetermined
  case .restricted:
    locationPermissions = .restricted
  case .denied:
    locationPermissions = .denied
  case .authorizedAlways:
    locationPermissions = .authorizedAlways
  case .authorizedWhenInUse:
    locationPermissions = .authorizedWhenInUse
  @unknown default:
    locationPermissions = .denied
  }
  return locationPermissions
}

func motionPermissions() -> MotionPermissions {
  switch CMMotionActivityManager.authorizationStatus() {
  case .notDetermined: return .notDetermined
  case .restricted: return .disabled
  case .denied: return.denied
  case .authorized: return .authorized
  @unknown default: return .denied
  }
}

func statusUpdate(_ state: SDKUnlockedStatus? = nil) -> SDKStatusUpdate {
  
  let sdk: SDKStatus
  switch ht {
  case let .some(ht):
    sdk = .unlocked(DeviceID(rawValue: NonEmptyString(rawValue: ht.deviceID)!), ht.isRunning ? .running : .stopped)
  case .none:
    sdk = .locked
  }
  
  return .init(
    permissions: Permissions(
      locationAccuracy: locationAccuracy(),
      locationPermissions: locationPermissions(),
      motionPermissions: motionPermissions()
    ),
    status: sdk
  )
}

func servicesAvailability() -> UntrackableReason? {
  CMMotionActivityManager.isActivityAvailable() ? nil : .motionActivityServicesUnavalible
}

extension String {
  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }
  
  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
}
