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
      .result {
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
    getCurrentLocation: {
      .future { callback in
        guard let lmd = lmd else { callback(.success(nil)); return }

        lmd.didUpdateLocations = { locations in
          callback(
            .success(
              locations.last
                .map(\.coordinate)
                .flatMap(Coordinate.init(coordinate2D:))
            )
          )
        }

        lmd.didFailWithError = {
          callback(.success(nil))
        }

        lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        lm.requestLocation()
      }
    },
    makeSDK: { pk in
      .result {
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
      .future { callback in
        logEffect("requestMotionPermissions")
        mm.queryActivityStarting(
          from: Date(),
          to: Date(),
          to: .main) { _, _ in
          callback(.success(statusUpdate()))
        }
      }
    },
    setName: { name in
      .fireAndForget {
        logEffect("setName: \(name.string)")
        
        ht?.setDeviceName(name.string)
      }
    },
    setMetadata: { metadata in
      .fireAndForget {
        let jsonString = String(data: try! JSONEncoder().encode(metadata), encoding: .utf8)!
        logEffect("setMetadata: \(jsonString)")
        
        ht?.setDeviceMetadata(HyperTrack.Metadata(jsonString: jsonString)!)
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
      .run { subscriber in
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
  var didUpdateLocations: (([CLLocation]) -> Void)?
  var didFailWithError: (() -> Void)?
  
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

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let didUpdateLocations = didUpdateLocations {
      didUpdateLocations(locations)
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let didFailWithError = didFailWithError {
      didFailWithError()
    }
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
