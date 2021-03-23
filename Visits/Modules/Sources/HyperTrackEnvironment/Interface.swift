import ComposableArchitecture
import DeviceID
import DriverID
import Prelude
import PublishableKey
import SDK
import UIKit
import Visit

public enum Geotag: Equatable {
  case cancel(Visit.ID, Visit.Source, Visit.VisitNote?)
  case checkOut(Visit.ID, Visit.Source, Visit.VisitNote?)
  case clockIn
  case clockOut
  case pickUp(Visit.ID, Visit.Source)
}

public struct HyperTrackEnvironment {
  public var addGeotag: (Geotag) -> Effect<Never, Never>
  public var checkDeviceTrackability: () -> Effect<UntrackableReason?, Never>
  public var didFailToRegisterForRemoteNotificationsWithError: (String) -> Effect<Never, Never>
  public var didReceiveRemoteNotification: ([String : [String : String]], @escaping (UIBackgroundFetchResult) -> Void) -> Effect<Never, Never>
  public var didRegisterForRemoteNotificationsWithDeviceToken: (Data) -> Effect<Never, Never>
  public var makeSDK: (PublishableKey) -> Effect<(SDKStatus, Permissions), Never>
  public var openSettings: () -> Effect<Never, Never>
  public var registerForRemoteNotifications: () -> Effect<Never, Never>
  public var requestLocationPermissions: () -> Effect<Never, Never>
  public var requestMotionPermissions: () -> Effect<(SDKStatus, Permissions), Never>
  public var setDriverID: (DriverID) -> Effect<Never, Never>
  public var startTracking: () -> Effect<Never, Never>
  public var stopTracking: () -> Effect<Never, Never>
  public var subscribeToStatusUpdates: () -> Effect<(SDKStatus, Permissions), Never>
  public var syncDeviceSettings: () -> Effect<Never, Never>

  public init(
    addGeotag: @escaping (Geotag) -> Effect<Never, Never>,
    checkDeviceTrackability: @escaping () -> Effect<UntrackableReason?, Never>,
    didFailToRegisterForRemoteNotificationsWithError: @escaping (String) -> Effect<Never, Never>,
    didReceiveRemoteNotification: @escaping ([String : [String : String]], @escaping (UIBackgroundFetchResult) -> Void) -> Effect<Never, Never>,
    didRegisterForRemoteNotificationsWithDeviceToken:  @escaping (Data) -> Effect<Never, Never>,
    makeSDK: @escaping (PublishableKey) -> Effect<(SDKStatus, Permissions), Never>,
    openSettings: @escaping () -> Effect<Never, Never>,
    registerForRemoteNotifications: @escaping () -> Effect<Never, Never>,
    requestLocationPermissions: @escaping () -> Effect<Never, Never>,
    requestMotionPermissions: @escaping () -> Effect<(SDKStatus, Permissions), Never>,
    setDriverID: @escaping (DriverID) -> Effect<Never, Never>,
    startTracking: @escaping () -> Effect<Never, Never>,
    stopTracking: @escaping () -> Effect<Never, Never>,
    subscribeToStatusUpdates: @escaping () -> Effect<(SDKStatus, Permissions), Never>,
    syncDeviceSettings: @escaping () -> Effect<Never, Never>
  ) {
    self.addGeotag = addGeotag
    self.checkDeviceTrackability = checkDeviceTrackability
    self.didFailToRegisterForRemoteNotificationsWithError = didFailToRegisterForRemoteNotificationsWithError
    self.didReceiveRemoteNotification = didReceiveRemoteNotification
    self.didRegisterForRemoteNotificationsWithDeviceToken = didRegisterForRemoteNotificationsWithDeviceToken
    self.makeSDK = makeSDK
    self.openSettings = openSettings
    self.registerForRemoteNotifications = registerForRemoteNotifications
    self.requestLocationPermissions = requestLocationPermissions
    self.requestMotionPermissions = requestMotionPermissions
    self.setDriverID = setDriverID
    self.startTracking = startTracking
    self.stopTracking = stopTracking
    self.subscribeToStatusUpdates = subscribeToStatusUpdates
    self.syncDeviceSettings = syncDeviceSettings
  }
}
