import ComposableArchitecture
import Combine
import Prelude

// MARK: - State

public struct SignInState: Equatable {
  public var credentials: Credentials
  public var isOnline: Bool
  
  public init(credentials: Credentials, isOnline: Bool) {
    self.credentials = credentials
    self.isOnline = isOnline
  }
}

public enum Credentials: Equatable {
  case complete(Complete)
  case incomplete(Incomplete)
}

public struct Incomplete: Equatable {
  var fields: Fields
  var state: FieldState
  
  public init(fields: Fields, state: FieldState) {
    self.fields = fields
    self.state = state
  }
}

public struct Complete: Equatable {
  public var email: NonEmptyString
  public var password: NonEmptyString
  public var requestStatus: RequestStatus
  
  public init(email: NonEmptyString, password: NonEmptyString, requestStatus: RequestStatus) {
    self.email = email
    self.password = password
    self.requestStatus = requestStatus
  }
}

public enum Fields: Equatable {
  case emailEntered(NonEmptyString)
  case empty
  case passwordEntered(NonEmptyString)
}

public enum Focus: Equatable {
  case email
  case password
  case none
}

public enum RequestStatus: Equatable {
  case inFlight
  case notSent(FieldState)
}

public struct FieldState: Equatable {
  public var error: String
  public var focus: Focus
}


extension SignInState {
  public static func initialState(isOnline: Bool) -> SignInState {
    SignInState(
      credentials: .incomplete(.initialState),
      isOnline: isOnline
    )
  }
}

extension FieldState {
  public static let initialState: FieldState =
    FieldState(error: "", focus: .none)
}

extension Incomplete {
  public static let initialState: Incomplete =
    Incomplete(fields: .empty, state: .initialState)
}

// MARK: - Action

public enum SignInAction: Equatable {
  public enum Done: Equatable {
    case goToForgotPassword
    case goToSignUp
    case signedIn(publishableKey: NonEmptyString)
  }
  
  public enum FocusTarget: Equatable {
    case dismissFocus
    case emailTextField
    case passwordTextField
  }
  
  case cancelSignIn
  case cancelSignInTimerFired
  case changeFocus(FocusTarget)
  case done(Done)
  case emailChanged(String)
  case handleForgotPasswordTransition
  case handleError(NonEmptyString)
  case handleSignInSuccess(publishableKey: NonEmptyString)
  case handleSignUpTransition
  case passwordChanged(String)
  case signInWithLowercasedEmail(email: NonEmptyString, password: NonEmptyString)
  case signInWithUserEnteredEmail(email: NonEmptyString, password: NonEmptyString)
  case tryToSignIn
}

extension Focus {
  init(focusTarget: SignInAction.FocusTarget) {
    switch focusTarget {
    case .dismissFocus:
      self = .none
    case .emailTextField:
      self = .email
    case .passwordTextField:
      self = .password
    }
  }
}

// MARK: - Environment

public typealias SignInEnvironment = (
  signIn: (_ email: NonEmptyString, _ password: NonEmptyString) -> Effect<PublishableKeyOrErrorString, Never>,
  signInDismissTimer: () -> Effect<Void, Never>
)

public let live = SignInEnvironment(
  signIn: signIn,
  signInDismissTimer: signInDismissTimer
)

public let mock = SignInEnvironment(
  signIn: { email, password in
    if email == "eugene@tulushev.com", password == "123456" {
      return Just(.left(NonEmptyString("uvIAA8xJANxUxDgINOX62-LINLuLeymS6JbGieJ9PegAPITcr9fgUpROpfSMdL9kv-qFjl17NeAuBHse8Qu9sw")))
        .delay(for: .seconds(5), scheduler: DispatchQueue.main)
        .eraseToEffect()
    } else {
      return Just(.right(NonEmptyString("Incorrect username or password"))).delay(for: .seconds(2), scheduler: DispatchQueue.main).eraseToEffect()
    }
},
  signInDismissTimer: signInDismissTimer
)

// MARK: - Reducer

struct CancelSignInToken: Hashable { static let shared = CancelSignInToken() }
struct CancelSignInTimerToken: Hashable { static let shared = CancelSignInTimerToken() }

public let signInReducer = Reducer<SignInState, SignInAction, SystemEnvironment<SignInEnvironment>> { state, action, environment in
  switch action {
  case .cancelSignIn:
    state.credentials = state.credentials
      |> /Credentials.complete >>> \.requestStatus .- .notSent(.initialState)
    return .concatenate(
      .cancel(id: CancelSignInTimerToken.shared),
      .cancel(id: CancelSignInToken.shared)
    )
  case .cancelSignInTimerFired:
    state.credentials = state.credentials
      |> /Credentials.complete >>> \.requestStatus .-
        .notSent(
          .initialState |> \.error .~ "Sign in request timed out. Please try again"
        )
    return .cancel(id: CancelSignInToken.shared)
  case let .changeFocus(target):
    let newFocus = Focus(focusTarget: target)
    state.credentials = state.credentials
      |> /Credentials.incomplete >>> \.state.focus .- newFocus
      <> /Credentials.complete
         >>> \.requestStatus
         >>> /RequestStatus.notSent
         >>> \.focus
           .- newFocus
    return .none
  case .done(_):
    // Responsibility of a parent
    return .none
  case let .emailChanged(email):
    if let email = NonEmptyString(rawValue: email.clean()) {
      switch state.credentials {
      case let .incomplete(credentials):
        switch credentials.fields {
        case .emailEntered, .empty:
          state.credentials = state.credentials
            |> /Credentials.incomplete >>> \.fields .- .emailEntered(email)
            <> /Credentials.incomplete >>> \.state.error .- ""
        case let .passwordEntered(password):
          state.credentials = .complete(
            .init(
              email: email,
              password: password,
              requestStatus: .notSent(
                .initialState |> \.focus .~ .email
              )
            )
          )
        }
      case .complete:
        state.credentials = state.credentials
          |> /Credentials.complete >>> \.email .- email
          <> /Credentials.complete
            >>> \.requestStatus
            >>> /RequestStatus.notSent
            >>> \.error
              .- ""
      }
    } else {
      switch state.credentials {
      case let .incomplete(credentials):
        switch credentials.fields {
        case .emailEntered:
          state.credentials = state.credentials
            |> /Credentials.incomplete >>> \.fields .- .empty
            <> /Credentials.incomplete >>> \.state.error .- ""
        case .empty, .passwordEntered:
          return .none
        }
      case let .complete(credentials):
        state.credentials = .incomplete(
          .init(
            fields: .passwordEntered(credentials.password),
            state: .init(error: "", focus: .email)
          )
        )
      }
    }
    return .none
  case .handleForgotPasswordTransition:
    if case let .complete(credentials) = state.credentials,
      case .inFlight = credentials.requestStatus {
      return .concatenate(
        .cancel(id: CancelSignInTimerToken.shared),
        .cancel(id: CancelSignInToken.shared),
        Effect(value: .done(.goToForgotPassword))
      )
    } else {
      return Effect(value: .done(.goToForgotPassword))
    }
  case let .handleError(error):
    state.credentials = state.credentials
      |> /Credentials.complete >>> \.requestStatus .- .notSent(
        .init(error: error.rawValue, focus: .email)
      )
    return .cancel(id: CancelSignInTimerToken.shared)
  case let .handleSignInSuccess(publishableKey):
    return .concatenate(
      .cancel(id: CancelSignInTimerToken.shared),
      Effect(value: .done(.signedIn(publishableKey: publishableKey)))
    )
  case .handleSignUpTransition:
    if case let .complete(credentials) = state.credentials,
      case .inFlight = credentials.requestStatus {
      return .concatenate(
        .cancel(id: CancelSignInTimerToken.shared),
        .cancel(id: CancelSignInToken.shared),
        Effect(value: .done(.goToSignUp))
      )
    } else {
      return Effect(value: .done(.goToSignUp))
    }
  case let .passwordChanged(password):
    if let password = NonEmptyString(rawValue: password.clean()) {
      switch state.credentials {
      case let .incomplete(credentials):
        switch credentials.fields {
        case .passwordEntered, .empty:
          state.credentials = state.credentials
            |> /Credentials.incomplete >>> \.fields .- .passwordEntered(password)
            <> /Credentials.incomplete >>> \.state.error .- ""
        case let .emailEntered(email):
          state.credentials = .complete(
            .init(
              email: email,
              password: password,
              requestStatus: .notSent(
                .initialState |> \.focus .~ .password
              )
            )
          )
        }
      case let .complete(credentials):
        state.credentials = state.credentials
        |> /Credentials.complete >>> \.password .- password
        <> /Credentials.complete
          >>> \.requestStatus
          >>> /RequestStatus.notSent
          >>> \.error
            .- ""
      }
    } else {
      switch state.credentials {
      case let .incomplete(credentials):
        switch credentials.fields {
        case .passwordEntered:
          state.credentials = state.credentials
            |> /Credentials.incomplete >>> \.fields .- .empty
            <> /Credentials.incomplete >>> \.state.error .- ""
        case .empty, .emailEntered:
          return .none
        }
      case let .complete(credentials):
        state.credentials = .incomplete(
          .init(
            fields: .emailEntered(credentials.email),
            state: .init(error: "", focus: .password)
          )
        )
      }
    }
    return .none
  case let .signInWithLowercasedEmail(email, password):
    return .merge(
      environment.signIn(NonEmptyString(stringLiteral: email.rawValue.lowercased()), password)
        .cancellable(id: CancelSignInToken.shared)
        .map { signInResult in
          switch signInResult {
          case let .left(publishableKey):
            return .handleSignInSuccess(publishableKey: publishableKey)
          case let .right(error):
            return .handleError(error)
          }
        }
        .receive(on: environment.mainQueue())
        .eraseToEffect(),
      environment.signInDismissTimer()
        .cancellable(id: CancelSignInTimerToken.shared)
        .map { .cancelSignInTimerFired }
        .receive(on: environment.mainQueue())
        .eraseToEffect()
    )
  case let .signInWithUserEnteredEmail(email, password):
    return .merge(
      environment.signIn(email, password)
        .cancellable(id: CancelSignInToken.shared)
        .map { signInResult in
          switch signInResult {
          case let .left(publishableKey):
            return .handleSignInSuccess(publishableKey: publishableKey)
          case let .right(error):
            return .signInWithLowercasedEmail(
              email: email,
              password: password
            )
          }
        }
        .receive(on: environment.mainQueue())
        .eraseToEffect(),
      environment.signInDismissTimer()
        .cancellable(id: CancelSignInTimerToken.shared)
        .map { .cancelSignInTimerFired }
        .receive(on: environment.mainQueue())
        .eraseToEffect()
    )
  case .tryToSignIn:
    switch  state.credentials {
    case let .incomplete(credentials):
      let please = "Please enter your "
      let email = "email"
      let password = "password"
      let error: String
      let focus: Focus
      switch credentials.fields {
      case .emailEntered:
        error = please + password
        focus = .password
      case .empty:
        error = please + email + " and " + password
        focus = .email
      case .passwordEntered:
        error = please + email
        focus = .email
      }
      
      state.credentials = state.credentials
        |> /Credentials.incomplete >>> \.state.error .- error
        <> /Credentials.incomplete >>> \.state.focus .- focus
      return .none
    case let .complete(credentials):
      guard case let .notSent(status) = credentials.requestStatus else {
        return .none
      }
      guard state.isOnline else {
        state.credentials = state.credentials
          |> /Credentials.complete
            >>> \.requestStatus >>> /RequestStatus.notSent >>> \.error
              .- "Internet connection unavailable"
        return .none
      }
      state.credentials = state.credentials
        |> /Credentials.complete >>> \.requestStatus .- .inFlight
      if credentials.email.rawValue == credentials.email.rawValue.lowercased() {
        return Effect(value: .signInWithLowercasedEmail(
          email: credentials.email,
          password: credentials.password
          )
        )
      } else {
        return Effect(value: .signInWithUserEnteredEmail(
          email: credentials.email,
          password: credentials.password
          )
        )
      }
    }
  }
}
