import Combine
import ComposableArchitecture
import CoreLocation
import CoreMotion
import HyperTrack
import HyperTrackEnvironment
import LogEnvironment
import NonEmpty
import Types
import UIKit
import Utility


extension String: Error {}

public extension HyperTrackEnvironment {
  static let live = Self(
    getCurrentLocation: {
      .result {
        let location = HyperTrack.location
        logEffect("getCurrentLocation: \(location)")
        return location
          .flatMap { location in
              .success(Coordinate(latitude: location.latitude, longitude: location.longitude))
          }
          .flatMapError { _ -> Result<_, Never> in
              .success(.none)
          }
      }
    },
    getMetadata: {
      .result {
        let metadata = HyperTrack.metadata
        logEffect("getMetadata: \(metadata)")
          return .success(fromHyperTrackMetadata(metadata))
      }
    },
    makeSDK: { pk in
      .result {
        logEffect("makeSDK: \(pk.string)")
        HyperTrack.dynamicPublishableKey = pk.string
        isUnlocked = true
        subscribe()
        return .success(statusUpdate(isTracking: HyperTrack.isTracking, isAvailable: HyperTrack.isAvailable, errors: HyperTrack.errors))
      }
    },
    openSettings: {
      .fireAndForget {
        logEffect("openSettings")
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
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
    setName: { name in
      .fireAndForget {
        logEffect("setName: \(name.string)")
        HyperTrack.name = name.string
      }
    },
    setMetadata: { metadata in
      .fireAndForget {
        logEffect("setMetadata: \(metadata)")
        HyperTrack.metadata = toHyperTrackMetadata(metadata)
      }
    },
    setWorkerHandle: { workerHandle in
      .fireAndForget {
        logEffect("setWorkerHandle: \(workerHandle.string)")
        HyperTrack.workerHandle = workerHandle.string
      }
    },
    startTracking: {
      .fireAndForget {
        logEffect("startTracking")
        HyperTrack.isTracking = true
      }
    },
    stopTracking: {
      .fireAndForget {
        logEffect("stopTracking")
        HyperTrack.isTracking = false
      }
    },
    subscribeToStatusUpdates: {
      .run { subscriber in
        logEffect("subscribeToStatusUpdates")
        statusUpdatesSubscriber = subscriber

        if isUnlocked {
          subscribe()
        }
        
        return AnyCancellable {
          cancellables = []
        }
      }
    }
  )
}

func subscribe() {
  if case let .some(subscriber) = statusUpdatesSubscriber {
    var isTracking = HyperTrack.isTracking
    var isAvailable = HyperTrack.isAvailable
    var errors = HyperTrack.errors

    cancellables.append(HyperTrack.subscribeToErrors({ newErrors in
      errors = newErrors
      subscriber.send(statusUpdate(isTracking: isTracking, isAvailable: isAvailable, errors: errors))
    }))

    cancellables.append(HyperTrack.subscribeToIsTracking({ newIsTracking in
      isTracking = newIsTracking
      subscriber.send(statusUpdate(isTracking: isTracking, isAvailable: isAvailable, errors: errors))
    }))

    cancellables.append(HyperTrack.subscribeToIsAvailable({ newIsAvailable in
      isAvailable = newIsAvailable
      subscriber.send(statusUpdate(isTracking: isTracking, isAvailable: isAvailable, errors: errors))
    }))
  }
}

var statusUpdatesSubscriber: Effect<SDKStatusUpdate, Never>.Subscriber? = nil

func fromHyperTrackMetadata(_ htJSON: HyperTrack.JSON.Object) -> JSON.Object {
  var json: JSON.Object = [:]
  for (key, value) in htJSON {
    json[key] = fromHyperTrackJSON(value)
  }
  return json
}

func fromHyperTrackJSON(_ htJSON: HyperTrack.JSON) -> JSON {
  switch htJSON {
  case let .object(o): return .object(fromHyperTrackMetadata(o))
  case let .array(a):  return .array(a.map(fromHyperTrackJSON))
  case let .string(s): return .string(s)
  case let .number(n): return .number(n)
  case let .bool(b):   return .bool(b)
  case .null:          return .null
  }
}

func toHyperTrackMetadata(_ json: JSON.Object) -> HyperTrack.JSON.Object {
  var htJSON: HyperTrack.JSON.Object = [:]
  for (key, value) in json {
    htJSON[key] = toHyperTrackJSON(value)
  }
  return htJSON
}

func toHyperTrackJSON(_ json: JSON) -> HyperTrack.JSON {
  switch json {
  case let .object(o): return .object(toHyperTrackMetadata(o))
  case let .array(a):  return .array(a.map(toHyperTrackJSON))
  case let .string(s): return .string(s)
  case let .number(n): return .number(n)
  case let .bool(b):   return .bool(b)
  case .null:          return .null
  }
}

var isUnlocked = false

let lm = CLLocationManager()

var cancellables: [HyperTrack.Cancellable] = []

func statusUpdate(isTracking: Bool, isAvailable: Bool, errors: Set<HyperTrack.Error>) -> SDKStatusUpdate {
  let sdk: SDKStatus
  if isUnlocked {
    sdk = .unlocked(DeviceID(rawValue: NonEmptyString(rawValue: HyperTrack.deviceID)!), unlockedStatus(isTracking: isTracking, isAvailable: isAvailable, errors: errors))
  } else {
    sdk = .locked
  }
  
  return .init(
    status: sdk
  )
}

func unlockedStatus(isTracking: Bool, isAvailable: Bool, errors: Set<HyperTrack.Error>) -> SDKUnlockedStatus {
  guard !errors.contains(.invalidPublishableKey) else {
    return .outage(.invalidPublishableKey)
  }
  guard !errors.contains(.blockedFromRunning) else {
    return .outage(.blockedFromRunning)
  }
  guard !errors.contains(.location(.mocked)) else {
    return .outage(.locationMocked)
  }
  guard !errors.contains(.location(.servicesDisabled)) else {
    return .outage(.locationServicesDisabled)
  }
  guard !errors.contains(.location(.signalLost)) else {
    return .outage(.locationSignalLost)
  }
  guard !errors.contains(.permissions(.location(.denied))) else {
    return .outage(.permissionLocationDenied)
  }
  guard !errors.contains(.permissions(.location(.insufficientForBackground))) else {
    return .outage(.permissionLocationInsufficientForBackground)
  }
  guard !errors.contains(.permissions(.location(.notDetermined))) else {
    return .outage(.permissionLocationNotDetermined)
  }
  guard !errors.contains(.permissions(.location(.provisional))) else {
    return .outage(.permissionLocationProvisional)
  }
  guard !errors.contains(.permissions(.location(.reducedAccuracy))) else {
    return .outage(.permissionLocationReducedAccuracy)
  }
  guard !errors.contains(.permissions(.location(.restricted))) else {
    return .outage(.permissionLocationRestricted)
  }

  if isTracking || isAvailable {
    return .running
  } else {
    return .stopped
  }
}

