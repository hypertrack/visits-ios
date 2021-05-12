import AppArchitecture
import ComposableArchitecture
import Prelude
import Types


// MARK: Action

public enum SignUpAction: Equatable {
  case dismissFocus
  case madeSDK(SDKStatusUpdate)
  case willEnterForeground
  // Form
  case focus(SignUpState.Form.Focus)
  case businessNameChanged(BusinessName?)
  case emailChanged(Email?)
  case passwordChanged(Password?)
  case completeSignUpForm
  //   Questions
  case selected(SignUpState.Questions.Status.Answering.Focus)
  case businessManagesChanged(BusinessManages?)
  case managesForChanged(ManagesFor?)
  case signUp
  case cancelSignUp
  case signedUp(Result<SignUpSuccess, APIError<CognitoError>>)
  //   Verification
  case verificationExtractedFromPasteboard(VerificationCode)
  case firstVerificationFieldChanged(String)
  case secondVerificationFieldChanged(String)
  case thirdVerificationFieldChanged(String)
  case fourthVerificationFieldChanged(String)
  case fifthVerificationFieldChanged(String)
  case sixthVerificationFieldChanged(String)
  case deleteVerificationDigit
  case focusVerification
  case resendVerificationCode
  case verificationCodeSent
  case receivedPublishableKey(PublishableKey)
  case autoSignInFailed(APIError<CognitoError>)
}

// Environment

public struct SignUpEnvironment {
  public var makeSDK: (PublishableKey) -> Effect<SDKStatusUpdate, Never>
  public var notifySuccess: () -> Effect<Never, Never>
  public var resendVerificationCode: (Email) -> Effect<Result<ResendVerificationSuccess, APIError<ResendVerificationError>>, Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>
  public var signUp: (BusinessName, Email, Password, BusinessManages, ManagesFor) -> Effect<Result<SignUpSuccess, APIError<CognitoError>>, Never>
  public var verificationCodeFromPasteboard: () -> Effect<VerificationCode?, Never>
  public var verifyEmail: (Email, VerificationCode) -> Effect<Result<PublishableKey, APIError<VerificationError>>, Never>
  
  public init(
    makeSDK: @escaping (PublishableKey) -> Effect<SDKStatusUpdate, Never>,
    notifySuccess: @escaping () -> Effect<Never, Never>,
    resendVerificationCode: @escaping (Email) -> Effect<Result<ResendVerificationSuccess, APIError<ResendVerificationError>>, Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError<CognitoError>>, Never>,
    signUp: @escaping (BusinessName, Email, Password, BusinessManages, ManagesFor) -> Effect<Result<SignUpSuccess, APIError<CognitoError>>, Never>,
    verificationCodeFromPasteboard: @escaping () -> Effect<VerificationCode?, Never>,
    verifyEmail: @escaping (Email, VerificationCode) -> Effect<Result<PublishableKey, APIError<VerificationError>>, Never>
  ) {
    self.makeSDK = makeSDK
    self.notifySuccess = notifySuccess
    self.resendVerificationCode = resendVerificationCode
    self.signIn = signIn
    self.signUp = signUp
    self.verificationCodeFromPasteboard = verificationCodeFromPasteboard
    self.verifyEmail = verifyEmail
  }
}

// Reducer

struct SignUpID: Hashable {}
struct VerifyID: Hashable {}
struct ResendVerificationID: Hashable {}
struct VerificationPasteboardSubscriptionID: Hashable {}

public func cancelSignUpEffects<Action>() -> Effect<Action, Never> {
  .merge(
    .cancel(id: SignUpID()),
    .cancel(id: VerifyID()),
    .cancel(id: ResendVerificationID()),
    .cancel(id: VerificationPasteboardSubscriptionID())
  )
}

public let signUpReducer = Reducer<SignUpState, SignUpAction, SystemEnvironment<SignUpEnvironment>> { state, action, environment in
  
  func makeSDK(_ pk: PublishableKey) -> Effect<SignUpAction, Never> {
      .merge(
        environment.makeSDK(pk)
          .receive(on: environment.mainQueue)
          .map(SignUpAction.madeSDK)
          .eraseToEffect(),
        cancelSignUpEffects()
      )
  }
  
  let checkVerificationCode = environment.verificationCodeFromPasteboard()
    .flatMap { (code: VerificationCode?) -> Effect<SignUpAction, Never> in
      switch code {
      case     .none:       return .none
      case let .some(code): return Effect(value: SignUpAction.verificationExtractedFromPasteboard(code))
      }
    }
    .receive(on: environment.mainQueue)
    .eraseToEffect()
  
  func verify(email: Email, password: Password, code: VerificationCode) -> Effect<SignUpAction, Never> {
    environment.verifyEmail(email, code)
      .receive(on: environment.mainQueue)
      .flatMap { (result: Result<PublishableKey, APIError<VerificationError>>) -> Effect<SignUpAction, Never> in
        let action: SignUpAction
        switch result {
        case let .success(pk):
          return Effect(value: .receivedPublishableKey(pk))
        case .failure(.error(.alreadyVerified)):
          return environment.signIn(email, password)
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .flatMap { (result: Result<PublishableKey, APIError<CognitoError>>) -> Effect<SignUpAction, Never> in
              switch result {
              case let .success(pk):
                return Effect(value: .receivedPublishableKey(pk))
              case let .failure(error):
                return Effect(value: SignUpAction.autoSignInFailed(error))
              }
            }
            .eraseToEffect()
        case let .failure(.error(.error(cognitoError))): action = SignUpAction.autoSignInFailed(.error(cognitoError))
        case let .failure(.network(network)):            action = SignUpAction.autoSignInFailed(.network(network))
        case let .failure(.unknown(d, r)):               action = SignUpAction.autoSignInFailed(.unknown(d, r))
        case let .failure(.api(e)):                      action = SignUpAction.autoSignInFailed(.api(e))
        case let .failure(.server(e)):                   action = SignUpAction.autoSignInFailed(.server(e))
        }
        return Effect(value: action)
      }
      .eraseToEffect()
      .cancellable(id: VerifyID(), cancelInFlight: true)
  }
  
  switch action {
  case .dismissFocus:
    
    switch state {
    case let .form(f):
      state = .form(f |> \.focus *< nil)
    case let .questions(q):
      state = .questions((q |> focusQuestionsAffine *<? nil) ?? q)
    case let .verification(v):
      state = .verification((v |> focusVerificationAffine *<? .unfocused) ?? v)
    }
    
    return .none
  
  case .madeSDK:
    return .none
    
    
  // MARK: - Form
  case let .focus(focus):
    guard case let .form(form) = state, form.focus != focus else { return .none }
    
    state = .form(form |> \.focus *< focus)
    
    return .none
  case let .businessNameChanged(bn):
    guard case let .form(f) = state else { return .none }
    
    switch f.status {
    case let .filling(fg):
      if let bn = bn, let e = fg.email, e.isValid(), let p = fg.password, p.isValid() {
        state = .form(f |> \.status *< .filled(.init(businessName: bn, email: e, password: p)))
      } else {
        state = .form(f |> \.status *< .filling(fg |> \.businessName *< bn))
      }
    case let .filled(fd):
      if let bn = bn {
        state = .form(f |> \.status *< .filled(fd |> \.businessName *< bn))
      } else {
        state = .form(f |> \.status *< .filling(.init(email: fd.email, password: fd.password)))
      }
    }
    
    return .none
  case let .emailChanged(e):
    guard case let .form(f) = state else { return .none }
    
    let e = e >>- { $0.cleanup() }
    
    switch f.status {
    case let .filling(fg):
      if let bn = fg.businessName, let e = e, e.isValid(), let p = fg.password, p.isValid() {
        state = .form(f |> \.status *< .filled(.init(businessName: bn, email: e, password: p)))
      } else {
        state = .form(f |> \.status *< .filling(fg |> \.email *< e))
      }
    case let .filled(fd):
      if let e = e, e.isValid() {
        state = .form(f |> \.status *< .filled(fd |> \.email *< e))
      } else {
        state = .form(f |> \.status *< .filling(.init(businessName: fd.businessName, email: e, password: fd.password)))
      }
    }
    
    return .none
  case let .passwordChanged(p):
    guard case let .form(f) = state else { return .none }
    
    switch f.status {
    case let .filling(fg):
      if let bn = fg.businessName, let e = fg.email, e.isValid(), let p = p, p.isValid() {
        state = .form(f |> \.status *< .filled(.init(businessName: bn, email: e, password: p)))
      } else {
        state = .form(f |> \.status *< .filling(fg |> \.password *< p))
      }
    case let .filled(fd):
      if let p = p, p.isValid() {
        state = .form(f |> \.status *< .filled(fd |> \.password *< p))
      } else {
        state = .form(f |> \.status *< .filling(.init(businessName: fd.businessName, email: fd.email, password: p)))
      }
    }
    
    return .none
  case .completeSignUpForm:
    guard case let .form(f) = state else { return .none }
    
    func error(_ e: CognitoError, _ s: inout SignUpState) {
      s = .form(f |> \.error *< e |> \.focus *< nil)
    }
    
    switch f.status {
    case let .filling(fg):
      switch (fg.businessName, fg.email, fg.password) {
      case (.none, _, _):
        error("Business name required", &state)
      case (_, .none, _):
        error("Please enter a valid email ID", &state)
      case let (_, .some(e), _) where !e.isValid():
        error("Please enter a valid email ID", &state)
      case (_, _, .none):
        error("Password should be 8 characters or more", &state)
      case let (_, _, .some(p)) where !p.isValid():
        error("Password should be 8 characters or more", &state)
      case let (.some(n), .some(e), .some(p)):
        state = .questions(.init(businessName: n, email: e, password: p, status: .answering(.init(focus: .businessManages))))
      }
    case let .filled(fd):
      state = .questions(
        .init(
          businessName: fd.businessName,
          email: fd.email,
          password: fd.password,
          status: .answering(.init(focus: .businessManages))
        )
      )
    }
    
    return .none
  
  
  // MARK: - Questions
  case let .selected(s):
    guard case let .questions(q) = state, case let .answering(a) = q.status else { return .none }
    
    state = .questions(q |> \.status *< .answering(a |> \.focus *< s))
    
    return .none
  case let .businessManagesChanged(bm):
    guard case let .questions(q) = state, case let .answering(a) = q.status else { return .none }
    
    state = .questions(q |> \.status *< .answering(a |> \.businessManages *< bm))
    
    return .none
  case let .managesForChanged(mf):
    guard case let .questions(q) = state, case let .answering(a) = q.status else { return .none }
    
    state = .questions(q |> \.status *< .answering(a |> \.managesFor *< mf))
    
    return .none
  case .signUp:
    guard case let .questions(q) = state,
          case let .answering(a) = q.status,
          let bm = a.businessManages,
          let mf = a.managesFor
    else { return .none }
    
    state = .questions(q |> \.status *< .signingUp(.init(businessManages: bm, managesFor: mf)))
    
    return environment.signUp(q.businessName, q.email, q.password, bm, mf)
      .receive(on: environment.mainQueue)
      .eraseToEffect()
      .map(SignUpAction.signedUp)
      .cancellable(id: SignUpID(), cancelInFlight: true)
  case .cancelSignUp:
    guard case let .questions(q) = state, case let .signingUp(s) = q.status else { return .none }
    
    state = .questions(q |> \.status *< .answering(.init(businessManages: s.businessManages, managesFor: s.managesFor)))
    
    return .cancel(id: SignUpID())
  case .signedUp(.success):
    guard case let .questions(q) = state, case let .signingUp(s) = q.status else { return .none }
    
    state = .verification(.init(status: .entering(.init(focus: .focused)), email: q.email, password: q.password))
    
    // Impossible without a timer because of an iOS bug: https://twitter.com/steipete/status/787985965432369152
    return Effect.timer(
      id: VerificationPasteboardSubscriptionID(),
      every: 5,
      on: environment.mainQueue
    )
    .receive(on: environment.mainQueue)
    .flatMap(constant(checkVerificationCode))
    .eraseToEffect()
  case let .signedUp(.failure(e)):
    guard case let .questions(q) = state, case let .signingUp(s) = q.status else { return .none }
    
    state = .questions(
      q |> \.status *< .answering(
        .init(
          businessManages: s.businessManages,
          managesFor: s.managesFor,
          error: e *^? /APIError<CognitoError>.error
        )
      )
    )
    
    return .none
    
  
  // MARK: - Verification
  case .willEnterForeground:
    guard case .verification = state else { return .none }
    
    return checkVerificationCode
  case let .verificationExtractedFromPasteboard(c):
    guard case let .verification(v) = state, case let .entering(e) = v.status else { return .none }
    
    state = .verification(v |> \.status *< .entered(.init(verificationCode: c, request: .inFlight)))
    
    return verify(email: v.email, password: v.password, code: c)
  case let .autoSignInFailed(e):
    if case let .verification(v) = state, case let .entering(eg) = v.status, eg.request == .inFlight {
      state = .verification(v |> \.status *< .entering(eg |> \.request *< nil <> \.focus *< .unfocused <> \.error *< e *^? /APIError<CognitoError>.error))
    } else if case let .verification(v) = state, case let .entered(en) = v.status, case .inFlight = en.request {
      state = .verification(v |> \.status *< .entering(.init(focus: .unfocused, error: e *^? /APIError<CognitoError>.error)))
    }
    
    return .none
  case .focusVerification:
    guard case let .verification(v) = state, case let .entering(e) = v.status else { return .none }
    
    state = .verification(v |> \.status *< .entering(e |> \.focus *< .focused))
    
    return .none
  case let .firstVerificationFieldChanged(s):
    guard case let .verification(v) = state,
          case let .entering(e) = v.status,
          e.codeEntry == nil
    else { return .none }
    
    if let v = VerificationCode(string: s) {
      return Effect(value: SignUpAction.verificationExtractedFromPasteboard(v))
    } else {
      if let d = VerificationCode.Digit(string: s) {
        state = .verification(v |> \.status *< .entering(e |> \.codeEntry *< .one(d)))
      }
    }
    
    return .none
  case let .secondVerificationFieldChanged(s):
    guard case let .verification(v) = state,
          case let .entering(e) = v.status,
          case let .one(d1) = e.codeEntry
    else { return .none }
    
    if let d = VerificationCode.Digit(string: s) {
      state = .verification(v |> \.status *< .entering(e |> \.codeEntry *< .two(d1, d)))
    }
    
    return .none
  case let .thirdVerificationFieldChanged(s):
    guard case let .verification(v) = state,
          case let .entering(e) = v.status,
          case let .two(d1, d2) = e.codeEntry
    else { return .none }
    
    if let d = VerificationCode.Digit(string: s) {
      state = .verification(v |> \.status *< .entering(e |> \.codeEntry *< .three(d1, d2, d)))
    }
    
    return .none
  case let .fourthVerificationFieldChanged(s):
    guard case let .verification(v) = state,
          case let .entering(e) = v.status,
          case let .three(d1, d2, d3) = e.codeEntry
    else { return .none }
    
    if let d = VerificationCode.Digit(string: s) {
      state = .verification(v |> \.status *< .entering(e |> \.codeEntry *< .four(d1, d2, d3, d)))
    }
    
    return .none
  case let .fifthVerificationFieldChanged(s):
    guard case let .verification(v) = state,
          case let .entering(e) = v.status,
          case let .four(d1, d2, d3, d4) = e.codeEntry
    else { return .none }
    
    if let d = VerificationCode.Digit(string: s) {
      state = .verification(v |> \.status *< .entering(e |> \.codeEntry *< .five(d1, d2, d3, d4, d)))
    }
    
    return .none
    
  case let .sixthVerificationFieldChanged(s):
    guard case let .verification(v) = state,
          case let .entering(e) = v.status,
          case let .five(d1, d2, d3, d4, d5) = e.codeEntry
    else { return .none }
    
    if let d = VerificationCode.Digit(string: s) {
      let c = VerificationCode(first: d1, second: d2, third: d3, fourth: d4, fifth: d5, sixth: d)
      
      state = .verification(v |> \.status *< .entered(.init(verificationCode: c, request: .inFlight)))
      
      return verify(email: v.email, password: v.password, code: c)
    }
    
    return .none
  case .deleteVerificationDigit:
    guard case let .verification(v) = state,
          case let .entering(e) = v.status,
          let ce = e.codeEntry
    else { return .none }
    
    let newCE: SignUpState.Verification.Status.Entering.CodeEntry?
    switch ce {
    case     .one:                      newCE = nil
    case let .two(d1, _):               newCE = .one(d1)
    case let .three(d1, d2, _):         newCE = .two(d1, d2)
    case let .four(d1, d2, d3, _):      newCE = .three(d1, d2, d3)
    case let .five(d1, d2, d3, d4, d5): newCE = .four(d1, d2, d3, d4)
    }
    state = .verification(v |> \.status *< .entering(e |> \.codeEntry *< newCE))
    
    return .none
  case .resendVerificationCode:
    guard case let .verification(v) = state, case let .entering(e) = v.status else { return .none }
    
    state = .verification(v |> \.status *< .entering(e |> \.request *< .inFlight))
    
    return .merge(
      environment.resendVerificationCode(v.email)
        .flatMap { (result: Result<ResendVerificationSuccess, APIError<ResendVerificationError>>) -> Effect<SignUpAction, Never> in
          let action: SignUpAction
          switch result {
          case .success:
            return Effect(value: .verificationCodeSent)
          case .failure(.error(.alreadyVerified)):
            return environment.signIn(v.email, v.password)
              .flatMap { (result: Result<PublishableKey, APIError<CognitoError>>) -> Effect<SignUpAction, Never> in
                switch result {
                case let .success(pk):
                  return Effect(value: .receivedPublishableKey(pk))
                case let .failure(error):
                  return Effect(value: SignUpAction.autoSignInFailed(error))
                }
              }
              .eraseToEffect()
          case let .failure(.error(.error(cognitoError))): action = SignUpAction.autoSignInFailed(.error(cognitoError))
          case let .failure(.network(network)):            action = SignUpAction.autoSignInFailed(.network(network))
          case let .failure(.unknown(d, r)):               action = SignUpAction.autoSignInFailed(.unknown(d, r))
          case let .failure(.api(e)):                      action = SignUpAction.autoSignInFailed(.api(e))
          case let .failure(.server(e)):                   action = SignUpAction.autoSignInFailed(.server(e))
          }
          return Effect(value: action)
        }
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .cancellable(id: ResendVerificationID(), cancelInFlight: true),
      environment.notifySuccess()
        .fireAndForget()
    )
  case .verificationCodeSent:
    guard case let .verification(v) = state, case let .entering(e) = v.status, e.request == .inFlight else { return .none }
    
    state = .verification(v |> \.status *< .entering(e |> \.request *< nil))
    
    return .none
  case let .receivedPublishableKey(pk):
    if case let .verification(v) = state, case let .entering(eg) = v.status, eg.request == .inFlight {
      state = .verification(v |> \.status *< .entering(eg |> \.request *< .success(pk)))
    } else if case let .verification(v) = state, case let .entered(ed) = v.status, case .inFlight = ed.request {
      state = .verification(v |> \.status *< .entered(ed |> \.request *< .success(pk)))
    }
    
    return makeSDK(pk)
  }
}

let focusQuestionsAffine = \SignUpState.Questions.status ** /SignUpState.Questions.Status.answering ** \.focus
let focusVerificationAffine = \SignUpState.Verification.status ** /SignUpState.Verification.Status.entering ** \.focus
