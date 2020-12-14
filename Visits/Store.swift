import App
import AppLive
import Architecture
import ComposableArchitecture
import Prelude

let store = Store<AppState, AppAction>(
  initialState: .initialState,
  reducer: appReducer,
  environment: SystemEnvironment.live(environment: AppEnvironment.live(signIn))
)

let viewStore = ViewStore.lifeCycleViewStore(from: store)
