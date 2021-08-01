import AppArchitecture
import ComposableArchitecture
import IntegrationLogic
import Utility
import Types


let integrationP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = integrationReducer.pullback(
  state: integrationStateAffine,
  action: integrationActionPrism,
  environment: constant(())
)

private let integrationStateAffine = /AppState.operational ** \.flow ** /AppFlow.main ** \.integrationStatus

private let integrationActionPrism = Prism<AppAction, IntegrationAction>(
  extract: { a in
    switch a {
    case let .integrationEntitiesUpdated(r): return .integrationEntitiesUpdated(r)
    default:                                 return nil
    }
  },
  embed: { a in
    switch a {
    case let .integrationEntitiesUpdated(r): return .integrationEntitiesUpdated(r)
    }
  }
)
