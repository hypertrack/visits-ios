import AppArchitecture
import ComposableArchitecture
import Prelude
import SignUpSignInToggleLogic
import Types


let signUpSignInToggleP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = signUpSignInToggleReducer.pullback(
  state: signUpSignInToggleStateAffine,
  action: signUpSignInToggleActionPrism,
  environment: constant(())
)


private let signUpSignInToggleStateAffine = /AppState.operational ** \OperationalState.flow ** signUpSignInToggleStatePrism

private let signUpSignInToggleActionPrism = Prism<AppAction, SignUpSignInToggleAction>(
  extract: { a in
    switch a {
    case .goToSignUp: return .goToSignUp
    case .goToSignIn: return .goToSignIn
    default:          return nil
    }
  },
  embed: { a in
    switch a {
    case .goToSignUp: return .goToSignUp
    case .goToSignIn: return .goToSignIn
    }
  }
)

private let signUpSignInToggleStatePrism = Prism<AppFlow, SignUpSignInToggleState>(
  extract: { a in
    switch a {
    case let .signUp(s): return .signUp(s)
    case let .signIn(s): return .signIn(s)
    default:             return nil
    }
  },
  embed: { s in
    switch s {
    case let .signUp(s): return .signUp(s)
    case let .signIn(s): return .signIn(s)
    }
  }
)
