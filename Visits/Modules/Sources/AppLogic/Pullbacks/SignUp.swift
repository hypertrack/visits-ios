import AppArchitecture
import ComposableArchitecture
import Prelude
import SignUpLogic
import Types


let signUpP: Reducer<
  AppState,
  AppAction,
  SystemEnvironment<AppEnvironment>
> = signUpReducer.pullback(
  state: signUpStateAffine,
  action: signUpActionPrism,
  environment: toSignUpEnvironment
)

func toSignUpState(_ a: AppState) -> SignUpState? { a *^? signUpStateAffine }

func _cancelSignUpEffects() -> Effect<AppAction, Never> { cancelSignUpEffects() }


private let signUpStateAffine = /AppState.operational ** \.flow ** /AppFlow.signUp

private let signUpActionPrism = Prism<AppAction, SignUpAction>(
  extract: { a in
    switch a {
    case     .dismissFocus:                           return .dismissFocus
    case let .madeSDK(s):                             return .madeSDK(s)
    case     .willEnterForeground:                    return .willEnterForeground
    case     .focusBusinessName:                      return .focus(.name)
    case     .focusEmail:                             return .focus(.email)
    case     .focusPassword:                          return .focus(.password)
    case let .businessNameChanged(bn):                return .businessNameChanged(bn)
    case let .emailChanged(e):                        return .emailChanged(e)
    case let .passwordChanged(p):                     return .passwordChanged(p)
    case     .completeSignUpForm:                     return .completeSignUpForm
    case     .businessManagesSelected:                return .selected(.businessManages)
    case     .managesForSelected:                     return .selected(.managesFor)
    case let .businessManagesChanged(bm):             return .businessManagesChanged(bm)
    case let .managesForChanged(mf):                  return .managesForChanged(mf)
    case     .signUp:                                 return .signUp
    case     .cancelSignUp:                           return .cancelSignUp
    case let .signedUp(r):                            return .signedUp(r)
    case let .verificationExtractedFromPasteboard(c): return .verificationExtractedFromPasteboard(c)
    case let .firstVerificationFieldChanged(s):       return .firstVerificationFieldChanged(s)
    case let .secondVerificationFieldChanged(s):      return .secondVerificationFieldChanged(s)
    case let .thirdVerificationFieldChanged(s):       return .thirdVerificationFieldChanged(s)
    case let .fourthVerificationFieldChanged(s):      return .fourthVerificationFieldChanged(s)
    case let .fifthVerificationFieldChanged(s):       return .fifthVerificationFieldChanged(s)
    case let .sixthVerificationFieldChanged(s):       return .sixthVerificationFieldChanged(s)
    case     .deleteVerificationDigit:                return .deleteVerificationDigit
    case     .focusVerification:                      return .focusVerification
    case     .resendVerificationCode:                 return .resendVerificationCode
    case let .autoSignInFailed(e):                    return .autoSignInFailed(e)
    case     .verificationCodeSent:                   return .verificationCodeSent
    case let .receivedPublishableKey(pk):             return .receivedPublishableKey(pk)
    default:                                          return nil
    }
  },
  embed: { a in
    switch a {
    case     .dismissFocus:                           return .dismissFocus
    case let .madeSDK(s):                             return .madeSDK(s)
    case     .willEnterForeground:                    return .willEnterForeground
    case     .focus(.name):                           return .focusBusinessName
    case     .focus(.email):                          return .focusEmail
    case     .focus(.password):                       return .focusPassword
    case let .businessNameChanged(bn):                return .businessNameChanged(bn)
    case let .emailChanged(e):                        return .emailChanged(e)
    case let .passwordChanged(p):                     return .passwordChanged(p)
    case     .completeSignUpForm:                     return .completeSignUpForm
    case     .selected(.businessManages):             return .businessManagesSelected
    case     .selected(.managesFor):                  return .managesForSelected
    case let .businessManagesChanged(bm):             return .businessManagesChanged(bm)
    case let .managesForChanged(mf):                  return .managesForChanged(mf)
    case     .signUp:                                 return .signUp
    case     .cancelSignUp:                           return .cancelSignUp
    case let .signedUp(r):                            return .signedUp(r)
    case let .verificationExtractedFromPasteboard(c): return .verificationExtractedFromPasteboard(c)
    case let .firstVerificationFieldChanged(s):       return .firstVerificationFieldChanged(s)
    case let .secondVerificationFieldChanged(s):      return .secondVerificationFieldChanged(s)
    case let .thirdVerificationFieldChanged(s):       return .thirdVerificationFieldChanged(s)
    case let .fourthVerificationFieldChanged(s):      return .fourthVerificationFieldChanged(s)
    case let .fifthVerificationFieldChanged(s):       return .fifthVerificationFieldChanged(s)
    case let .sixthVerificationFieldChanged(s):       return .sixthVerificationFieldChanged(s)
    case     .deleteVerificationDigit:                return .deleteVerificationDigit
    case     .focusVerification:                      return .focusVerification
    case     .resendVerificationCode:                 return .resendVerificationCode
    case let .autoSignInFailed(e):                    return .autoSignInFailed(e)
    case     .verificationCodeSent:                   return .verificationCodeSent
    case let .receivedPublishableKey(pk):             return .receivedPublishableKey(pk)
    }
  }
)

private func toSignUpEnvironment(_ e: SystemEnvironment<AppEnvironment>) -> SystemEnvironment<SignUpEnvironment> {
  e.map { e in
    .init(
      makeSDK: e.hyperTrack.makeSDK,
      notifySuccess: e.hapticFeedback.notifySuccess,
      resendVerificationCode: e.api.resendVerificationCode,
      signIn: e.api.signIn,
      signUp: e.api.signUp,
      verificationCodeFromPasteboard: e.pasteboard.verificationCodeFromPasteboard,
      verifyEmail: e.api.verifyEmail
    )
  }
}
