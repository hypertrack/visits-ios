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
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case let .integrationEntitiesUpdatedWithFailure(e):   return .integrationEntitiesUpdatedWithFailure(e)
    default:                                              return nil
    }
  },
  embed: { a in
    switch a {
    case let .integrationEntitiesUpdatedWithSuccess(ies): return .integrationEntitiesUpdatedWithSuccess(ies)
    case let .integrationEntitiesUpdatedWithFailure(e):   return .integrationEntitiesUpdatedWithFailure(e)
    }
  }
)
