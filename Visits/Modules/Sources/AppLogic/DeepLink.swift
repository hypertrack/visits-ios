import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Prelude
import Tagged
import Types


let deepLinkReducer: Reducer<AppState, AppAction, SystemEnvironment<AppEnvironment>> = Reducer { state, action, environment in
  switch (state.flow, action) {
  case (.appLaunching, .restoredState(.left(.deepLink), _)):
    return Effect(value: .deepLinkFirstRunWaitingComplete)
      .delay(for: .seconds(3), scheduler: environment.mainQueue())
      .eraseToEffect()
  case (.firstRun, .deepLinkFirstRunWaitingComplete):
    return Effect(value: .appHandleFirstRunFlow)
  case let (_, .deepLinkOpened(a)):
    return environment
      .deepLink
      .continueUserActivity(a)
      .fireAndForget()
  case (_, .stateRestored):
    return environment
      .deepLink
      .subscribeToDeepLinks()
      .receive(on: environment.mainQueue())
      .flatMap { (pk: PublishableKey, drID: DriverID?) -> Effect<AppAction, Never> in
        guard let drID = drID else {
          return Effect(value: .appHandleDriverIDFlow(pk))
        }
        return environment.hyperTrack
          .makeSDK(pk)
          .receive(on: environment.mainQueue())
          .flatMap { (status: SDKStatus, permissions: Permissions) -> Effect<AppAction, Never> in
            switch status {
            case .locked:
              return Effect(value: AppAction.appHandleSDKLocked)
            case let .unlocked(deviceID, unlockedStatus):
              return .merge(
                Effect(value: AppAction.appHandleSDKUnlocked(pk, drID, deviceID, unlockedStatus, permissions, .dialogSplash(.notShown), .firstRun)),
                environment.hyperTrack
                  .subscribeToStatusUpdates()
                  .receive(on: environment.mainQueue())
                  .eraseToEffect()
                  .map(AppAction.statusUpdated),
                environment.hyperTrack
                  .setDriverID(driverID)
                  .eraseToEffect()
                  .fireAndForget()
              )
            }
          }
          .eraseToEffect()
      }
      .eraseToEffect()
  default:
    return .none
  }
}
