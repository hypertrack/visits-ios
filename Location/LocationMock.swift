import ComposableArchitecture
import Prelude

extension LocationManagerClient {
  static func mock(
    startMonitoringPermissions: @escaping () -> Effect<LocationPermissions, Never> =
      unzurry(Effect(value: .granted))
  ) -> Self {
    Self(
      startMonitoringPermissions: startMonitoringPermissions,
      requestPermissions: { .none }
    )
  }
}
