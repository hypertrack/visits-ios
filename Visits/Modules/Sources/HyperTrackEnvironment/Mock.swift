import Combine
import ComposableArchitecture
import Types


public extension HyperTrackEnvironment {
  static let noop = Self(
    getCurrentLocation: { .none },
    makeSDK: { _ in .none},
    openSettings: { .none },
    requestAlwaysLocationPermissions: { .none },
    requestWhenInUseLocationPermissions: { .none },
    setName: { _ in .none},
    setMetadata: { _ in .none},
    setWorkerHandle: { _ in .none},
    startTracking: { .none },
    stopTracking: { .none },
    subscribeToStatusUpdates: { .none }
  )

  static func simulator(deviceID: DeviceID, publishableKey: PublishableKey) -> Self {
    var s = SDKStatus.locked
    
    let statusUpdateSubject = PassthroughSubject<SDKStatusUpdate, Never>()

    return Self(
      getCurrentLocation: noop.getCurrentLocation,
      makeSDK: { _ in
        s = .unlocked(deviceID, .stopped)
        
        return Effect(value: .init(status: s))
      },
      openSettings: {
        statusUpdateSubject.send(.init(status: s))
        
        return .none
      },
      requestAlwaysLocationPermissions: {
        statusUpdateSubject.send(.init(status: s))
        
        return .none
      },
      requestWhenInUseLocationPermissions: {
        statusUpdateSubject.send(.init(status: s))
        
        return .none
      },
      setName: noop.setName,
      setMetadata: noop.setMetadata,
      setWorkerHandle: noop.setWorkerHandle,
      startTracking: {
        s = .unlocked(deviceID, .running)
        statusUpdateSubject.send(.init(status: s))
        
        return .none
      },
      stopTracking: {
        s = .unlocked(deviceID, .stopped)
        statusUpdateSubject.send(.init(status: s))
        
        return .none
      },
      subscribeToStatusUpdates: {
        .merge(
          statusUpdateSubject.eraseToEffect(),
          .fireAndForget { statusUpdateSubject.send(.init(status: s)) })
      }
    )
  }
}
