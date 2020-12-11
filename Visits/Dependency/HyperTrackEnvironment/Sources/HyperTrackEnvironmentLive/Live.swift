import Combine
import ComposableArchitecture
import CoreLocation
import CoreMotion
import DeviceID
import DriverID
import HyperTrack
import HyperTrackEnvironment
import Log
import NonEmpty
import PublishableKey
import SDK

extension String: Error {}

public extension HyperTrackEnvironment {
  static let live = Self(
    addGeotag: { geotag in
      .fireAndForget {
        logEffect("addGeotag: \(geotag)")
        let metadata: [String: String]
        switch geotag {
        case let .cancel(a):
          metadata =
            [
              fromAssignedSource(a.source): a.id.rawValue.rawValue,
              C.type.rawValue: C.cancel.rawValue,
              C.visitNote.rawValue: a.visitNote?.rawValue.rawValue ?? ""
            ]
        case let .checkIn(.left(m)):
          metadata =
            [
              C.visitID.rawValue: m.rawValue.rawValue,
              C.type.rawValue: C.checkIn.rawValue
            ]
        case let .checkIn(.right(a)):
          metadata =
            [
              fromAssignedSource(a.source): a.id.rawValue.rawValue,
              C.type.rawValue: C.checkIn.rawValue
            ]
        case let .checkOut(.left(m)):
          metadata =
            [
              C.visitID.rawValue: m.id.rawValue.rawValue,
              C.type.rawValue: C.checkOut.rawValue,
              C.visitNote.rawValue: m.visitNote?.rawValue.rawValue ?? ""
            ]
        case let .checkOut(.right(a)):
          metadata =
            [
              fromAssignedSource(a.source): a.id.rawValue.rawValue,
              C.type.rawValue: C.checkOut.rawValue,
              C.visitNote.rawValue: a.visitNote?.rawValue.rawValue ?? ""
            ]
        case .clockIn:
          metadata = [C.type.rawValue: C.clockIn.rawValue]
        case .clockOut:
          metadata = [C.type.rawValue: C.clockOut.rawValue]
        case let .pickUp(id, s):
          metadata =
            [
              fromAssignedSource(s): id.rawValue.rawValue,
              C.type.rawValue: C.pickUp.rawValue,
            ]
        }
        ht?.addGeotag(HyperTrack.Metadata(rawValue: metadata)!)
      }
    },
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
        logEffect("makeSDK: \(pk.rawValue.rawValue)")
        ht = try! HyperTrack(publishableKey: HyperTrack.PublishableKey(pk.rawValue.rawValue)!)
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
    requestLocationPermissions: {
      .fireAndForget {
        logEffect("requestLocationPermissions")
        lm.requestAlwaysAuthorization()
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
    setDriverID: { dID in
      .fireAndForget {
        logEffect("setDriverID: \(dID.rawValue.rawValue)")
        ht?.setDeviceMetadata(
          HyperTrack.Metadata(
            dictionary: [C.driverID.rawValue: dID.rawValue.rawValue]
          )!
        )
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

func fromAssignedSource(_ source: A.Source) -> String {
  switch source {
  case .geofence: return C.geofenceID.rawValue
  case .trip: return C.tripID.rawValue
  }
}

enum C: String {
  case cancel = "CANCEL"
  case checkIn = "CHECK_IN"
  case checkOut = "CHECK_OUT"
  case clockIn = "CLOCK_IN"
  case clockOut = "CLOCK_OUT"
  case visitNote = "visit_note"
  case driverID = "driver_id"
  case geofenceID = "geofence_id"
  case tripID = "trip_id"
  case pickUp = "PICK_UP"
  case type = "type"
  case visitID = "visit_id"
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
  let accuracy: LocationAccuracy
  if #available(iOS 14, *) {
    switch lm.accuracyAuthorization {
    case .fullAccuracy:
      accuracy = .full
    case .reducedAccuracy:
      accuracy = .reduced
    @unknown default:
      accuracy = .reduced
    }
  } else {
    accuracy = .full
  }
  return accuracy
}

func locationPermissions() -> LocationPermissions {
  let locationPermissions: LocationPermissions
  let locationAuthorization: CLAuthorizationStatus
  if #available(iOS 14, *) {
    locationAuthorization = lm.authorizationStatus
  } else {
    locationAuthorization = CLLocationManager.authorizationStatus()
  }
  switch locationAuthorization {
  case .notDetermined:
    locationPermissions = .notDetermined
  case .restricted:
    locationPermissions = .restricted
  case .denied:
    locationPermissions = .denied
  case .authorizedAlways, .authorizedWhenInUse:
    locationPermissions = .authorized
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

func statusUpdate(_ state: SDKUnlockedStatus? = nil) -> (SDKStatus, Permissions) {
  
  let sdk: SDKStatus
  switch ht {
  case let .some(ht):
    sdk = .unlocked(DeviceID(rawValue: NonEmptyString(rawValue: ht.deviceID)!), ht.isRunning ? .running : .stopped)
  case .none:
    sdk = .locked
  }
  
  return (
    sdk,
    Permissions(
      locationAccuracy: locationAccuracy(),
      locationPermissions: locationPermissions(),
      motionPermissions: motionPermissions()
    )
  )
}

func servicesAvailability() -> UntrackableReason? {
  CMMotionActivityManager.isActivityAvailable() ? nil : .motionActivityServicesUnavalible
}
