import AppArchitecture
import ComposableArchitecture
import Utility
import SignInLogic
import Types


let signInP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = signInReducer.pullback(
  state: signInStateAffine,
  action: signInActionPrism,
  environment: toSignInEnvironment
)

func toSignInState(_ a: AppState) -> SignInState? { a *^? signInStateAffine }

func _cancelSignInEffects() -> Effect<AppAction, Never> { cancelSignInEffects() }


private let signInStateAffine = /AppState.operational ** \.flow ** /AppFlow.signIn

private let signInActionPrism = Prism<AppAction, SignInAction>(
  extract: { a in
    switch a {
    case     .focusEmail:         return .focusEmail
    case     .focusPassword:      return .focusPassword
    case     .dismissFocus:       return .dismissFocus
    case let .emailChanged(e):    return .emailChanged(e)
    case let .passwordChanged(p): return .passwordChanged(p)
    case     .signIn:             return .signIn
    case     .cancelSignIn:       return .cancelSignIn
    case let .signedIn(r):        return .signedIn(r)
    case let .madeSDK(s):         return .madeSDK(s)
    default:                      return nil
    }
  },
  embed: { a in
    switch a {
    case     .focusEmail:         return .focusEmail
    case     .focusPassword:      return .focusPassword
    case     .dismissFocus:       return .dismissFocus
    case let .emailChanged(e):    return .emailChanged(e)
    case let .passwordChanged(p): return .passwordChanged(p)
    case     .signIn:             return .signIn
    case     .cancelSignIn:       return .cancelSignIn
    case let .signedIn(r):        return .signedIn(r)
    case let .madeSDK(s):         return .madeSDK(s)
    }
  }
)

private func toSignInEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<SignInEnvironment> {
  e.map { e in
    .init(
      makeSDK: e.hyperTrack.makeSDK,
      signIn: e.api.signIn
    )
  }
}
