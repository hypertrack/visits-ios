import AppLogic
import AppLive
import AppArchitecture
import ComposableArchitecture
import Types


let store = Store<AppState, AppAction>(
  reducer: appReducer,
  environment: SystemEnvironment.live(environment: AppEnvironment.live)
)

let viewStore = ViewStore.lifeCycleViewStore(from: store)
