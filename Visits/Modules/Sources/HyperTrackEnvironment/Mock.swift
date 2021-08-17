import Combine
import ComposableArchitecture
import Types


public extension HyperTrackEnvironment {
  static let noop = Self(
    checkDeviceTrackability: { .none },
    didFailToRegisterForRemoteNotificationsWithError: { _ in .none},
    didReceiveRemoteNotification: { _, _ in .none },
    didRegisterForRemoteNotificationsWithDeviceToken: { _ in .none},
    getCurrentLocation: { .none },
    makeSDK: { _ in .none},
    openSettings: { .none },
    registerForRemoteNotifications: { .none },
    requestAlwaysLocationPermissions: { .none },
    requestWhenInUseLocationPermissions: { .none },
    requestMotionPermissions: { .none },
    setName: { _ in .none},
    setMetadata: { _ in .none},
    startTracking: { .none },
    stopTracking: { .none },
    subscribeToStatusUpdates: { .none },
    syncDeviceSettings: { .none }
  )

  static func simulator(deviceID: DeviceID, publishableKey: PublishableKey) -> Self {
    var p = Permissions(locationAccuracy: .full, locationPermissions: .notDetermined, motionPermissions: .notDetermined)
    var s = SDKStatus.locked
    
    let statusUpdateSubject = PassthroughSubject<SDKStatusUpdate, Never>()

    return Self(
      checkDeviceTrackability: { Effect(value: nil) },
      didFailToRegisterForRemoteNotificationsWithError: noop.didFailToRegisterForRemoteNotificationsWithError,
      didReceiveRemoteNotification: noop.didReceiveRemoteNotification,
      didRegisterForRemoteNotificationsWithDeviceToken: noop.didRegisterForRemoteNotificationsWithDeviceToken,
      getCurrentLocation: noop.getCurrentLocation,
      makeSDK: { _ in
        s = .unlocked(deviceID, .stopped)
        
        return Effect(value: .init(permissions: p, status: s))
      },
      openSettings: {
        p.locationPermissions = .authorizedAlways
        statusUpdateSubject.send(.init(permissions: p, status: s))
        
        return .none
      },
      registerForRemoteNotifications: noop.registerForRemoteNotifications,
      requestAlwaysLocationPermissions: {
        p.locationPermissions = .authorizedAlways
        statusUpdateSubject.send(.init(permissions: p, status: s))
        
        return .none
      },
      requestWhenInUseLocationPermissions: {
        p.locationPermissions = .authorizedWhenInUse
        statusUpdateSubject.send(.init(permissions: p, status: s))
        
        return .none
      },
      requestMotionPermissions: {
        p.motionPermissions = .authorized
        
        return Effect(value: .init(permissions: p, status: s))
      },
      setName: noop.setName,
      setMetadata: noop.setMetadata,
      startTracking: {
        s = .unlocked(deviceID, .running)
        statusUpdateSubject.send(.init(permissions: p, status: s))
        
        return .none
      },
      stopTracking: {
        s = .unlocked(deviceID, .stopped)
        statusUpdateSubject.send(.init(permissions: p, status: s))
        
        return .none
      },
      subscribeToStatusUpdates: {
        .merge(
          statusUpdateSubject.eraseToEffect(),
          .fireAndForget { statusUpdateSubject.send(.init(permissions: p, status: s)) })
      },
      syncDeviceSettings: noop.syncDeviceSettings
    )
  }
  
  
}
