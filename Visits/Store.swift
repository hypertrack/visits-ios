import AppLogic
import AppLive
import AppArchitecture
import ComposableArchitecture


let store = Store<AppState, AppAction>(
  initialState: .initialState,
  reducer: appReducer,
  environment: SystemEnvironment.live(environment: AppEnvironment.live)
)

let viewStore = ViewStore.lifeCycleViewStore(from: store)
