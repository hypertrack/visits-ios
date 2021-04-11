import Combine
import ComposableArchitecture
import Types


public extension HyperTrackEnvironment {
  static let noop = Self(
    addGeotag: { _ in .none},
    checkDeviceTrackability: { .none },
    didFailToRegisterForRemoteNotificationsWithError: { _ in .none},
    didReceiveRemoteNotification: { _, _ in .none },
    didRegisterForRemoteNotificationsWithDeviceToken: { _ in .none},
    makeSDK: { _ in .none},
    openSettings: { .none },
    registerForRemoteNotifications: { .none },
    requestLocationPermissions: { .none },
    requestMotionPermissions: { .none },
    setDriverID: { _ in .none},
    startTracking: { .none },
    stopTracking: { .none },
    subscribeToStatusUpdates: { .none },
    syncDeviceSettings: { .none }
  )

  static func simulator(deviceID: DeviceID, publishableKey: PublishableKey) -> Self {
    let tracking = (SDKStatus.unlocked(deviceID, .running), Permissions.granted)
    let notTracking = (SDKStatus.unlocked(deviceID, .stopped), Permissions.granted)
    
    let statusUpdateSubject = PassthroughSubject<(SDKStatus, Permissions), Never>()

    return Self(
      addGeotag: noop.addGeotag,
      checkDeviceTrackability: { Effect(value: nil) },
      didFailToRegisterForRemoteNotificationsWithError: noop.didFailToRegisterForRemoteNotificationsWithError,
      didReceiveRemoteNotification: noop.didReceiveRemoteNotification,
      didRegisterForRemoteNotificationsWithDeviceToken: noop.didRegisterForRemoteNotificationsWithDeviceToken,
      makeSDK: { _ in Effect(value: notTracking) },
      openSettings: noop.openSettings,
      registerForRemoteNotifications: noop.registerForRemoteNotifications,
      requestLocationPermissions: noop.requestLocationPermissions,
      requestMotionPermissions: { Effect(value: notTracking) },
      setDriverID: noop.setDriverID,
      startTracking: { statusUpdateSubject.send(tracking); return .none },
      stopTracking: { statusUpdateSubject.send(notTracking); return .none },
      subscribeToStatusUpdates: { statusUpdateSubject.eraseToEffect() },
      syncDeviceSettings: noop.syncDeviceSettings
    )
  }
  
  
}
