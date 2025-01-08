import ComposableArchitecture
import Utility
import Types
import UIKit


public struct HyperTrackEnvironment {
  public var getCurrentLocation: () -> Effect<Coordinate?, Never>
  public var makeSDK: (PublishableKey) -> Effect<SDKStatusUpdate, Never>
  public var openSettings: () -> Effect<Never, Never>
  public var requestAlwaysLocationPermissions: () -> Effect<Never, Never>
  public var requestWhenInUseLocationPermissions: () -> Effect<Never, Never>
  public var setName: (Name) -> Effect<Never, Never>
  public var setMetadata: (JSON.Object) -> Effect<Never, Never>
  public var setWorkerHandle: (WorkerHandle) -> Effect<Never, Never>
  public var startTracking: () -> Effect<Never, Never>
  public var stopTracking: () -> Effect<Never, Never>
  public var subscribeToStatusUpdates: () -> Effect<SDKStatusUpdate, Never>

  public init(
    getCurrentLocation: @escaping () -> Effect<Coordinate?, Never>,
    makeSDK: @escaping (PublishableKey) -> Effect<SDKStatusUpdate, Never>,
    openSettings: @escaping () -> Effect<Never, Never>,
    requestAlwaysLocationPermissions: @escaping () -> Effect<Never, Never>,
    requestWhenInUseLocationPermissions: @escaping () -> Effect<Never, Never>,
    setName: @escaping (Name) -> Effect<Never, Never>,
    setMetadata: @escaping (JSON.Object) -> Effect<Never, Never>,
    setWorkerHandle: @escaping (WorkerHandle) -> Effect<Never, Never>,
    startTracking: @escaping () -> Effect<Never, Never>,
    stopTracking: @escaping () -> Effect<Never, Never>,
    subscribeToStatusUpdates: @escaping () -> Effect<SDKStatusUpdate, Never>
  ) {
    self.getCurrentLocation = getCurrentLocation
    self.makeSDK = makeSDK
    self.openSettings = openSettings
    self.requestAlwaysLocationPermissions = requestAlwaysLocationPermissions
    self.requestWhenInUseLocationPermissions = requestWhenInUseLocationPermissions
    self.setName = setName
    self.setMetadata = setMetadata
    self.setWorkerHandle = setWorkerHandle
    self.startTracking = startTracking
    self.stopTracking = stopTracking
    self.subscribeToStatusUpdates = subscribeToStatusUpdates
  }
}
