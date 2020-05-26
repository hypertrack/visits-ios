import Combine
import CoreLocation
import UIKit

import ComposableArchitecture

import Location


extension LocationEnvironment {
  public static let live = LocationEnvironment(
    locationManagerClient: .live,
    openSettings: {
      .fireAndForget {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
      }
    }
  )
}

extension LocationManagerClient {
  public static let live = LocationManagerClient(
    startMonitoringPermissions: {
      Effect.async { subscriber in
        let delegate = LocationManagerClientDelegate(
          didChangeAuthorization: subscriber.send
        )
        dependency = delegate
        return AnyCancellable { dependency = nil }
      }
    },
    requestPermissions: { .fireAndForget { dependency?.requestPermissions() } }
  )
}

private var dependency: LocationManagerClientDelegate?

private class LocationManagerClientDelegate: NSObject, CLLocationManagerDelegate {
  let didChangeAuthorization: (LocationPermissions) -> Void
  
  let locationManager: CLLocationManager
  
  init(didChangeAuthorization: @escaping (LocationPermissions) -> Void) {
    self.didChangeAuthorization = didChangeAuthorization
    self.locationManager = CLLocationManager()
    super.init()
    self.locationManager.delegate = self
  }
  
  func requestPermissions() {
    locationManager.requestAlwaysAuthorization()
  }
  
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    switch status {
    case .notDetermined:
      self.didChangeAuthorization(.notRequested)
    case .restricted:
      self.didChangeAuthorization(.restricted)
    case .denied:
      if CLLocationManager.locationServicesEnabled() {
        self.didChangeAuthorization(.denied)
      } else {
        self.didChangeAuthorization(.disabled)
      }
    case .authorizedAlways, .authorizedWhenInUse:
      self.didChangeAuthorization(.granted)
    @unknown default:
      fatalError()
    }
  }
}
