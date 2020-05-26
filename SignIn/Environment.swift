import Combine

import AWSMobileClient

import ComposableArchitecture
import Prelude

extension NonEmptyString: Error {}

public typealias PublishableKeyOrErrorString = Either<NonEmptyString, NonEmptyString>

public func signIn(email: NonEmptyString, password: NonEmptyString) -> Effect<PublishableKeyOrErrorString, Never> {
  return initializeFuture()
    .flatMap { _ in signOutFuture() }
    .flatMap { _ in signInFuture(email: email, password: password) }
    .flatMap { _ in getTokensFuture() }
    .flatMap { getPublishableKeyFuture(auth: $0) }
    .map { PublishableKeyOrErrorString.left($0) }
    .catch { Just(PublishableKeyOrErrorString.right($0)) }
    .eraseToEffect()
}

public func signInDismissTimer() -> Effect<Void, Never> {
  Just(())
    .delay(for: .seconds(20), scheduler: DispatchQueue.main)
    .eraseToEffect()
}

// MARK: - AWSMobileClient

let configuration = [
  "IdentityManager": [
    "Default": [:]
  ],
  "CognitoUserPool": [
    "Default": [
      "PoolId": "us-west-2_HMxGvgUyF",
      "AppClientId": "7n7mfrkmvb8am9d1n3e79mcdsd",
      "Region": "us-west-2"
    ]
  ]
]
let mobileClient = AWSMobileClient(configuration: configuration)


struct PublishableKeyResult: Decodable {
  let key: String
}

// MARK: - Pipeline

func initializeFuture() -> AnyPublisher<Void, NonEmptyString> {
  Future<Void, NonEmptyString> { promise in
    mobileClient.initialize { optionalUserState, optionalError in
      if let _ = optionalUserState {
        promise(.success(()))
      } else if let error = optionalError {
        promise(.failure(fromAWSError(error)))
      } else {
         promise(.failure(failedToSignIn("pEhwy")))
      }
    }
  }
  .eraseToAnyPublisher()
}

func signOutFuture() -> AnyPublisher<Void, NonEmptyString> {
  Future<Void, NonEmptyString> { promise in
    mobileClient.signOut { error in
      if let nonNilError = error {
        promise(.failure(fromAWSError(nonNilError)))
      } else {
        promise(.success(()))
      }
    }
  }
  .eraseToAnyPublisher()
}

func signInFuture(
  email: NonEmptyString,
  password: NonEmptyString
) -> AnyPublisher<Void, NonEmptyString> {
  Future<Void, NonEmptyString> { promise in
    mobileClient.signIn(
    username: email.rawValue,
    password: password.rawValue
    ) { optionalSignInResult, optionalError in
      if let signInResult = optionalSignInResult {
        switch signInResult.signInState {
        case .signedIn:
          promise(.success(()))
        default:
          promise(.failure(failedToSignIn(signInResult.signInState.rawValue)))
        }
      } else {
        promise(.failure(fromAWSError(optionalError!)))
      }
    }
  }
  .eraseToAnyPublisher()
}

func getTokensFuture() -> AnyPublisher<NonEmptyString, NonEmptyString> {
  Future<NonEmptyString, NonEmptyString> { promise in
    mobileClient.getTokens { tokens, error in
      if let idToken = tokens?.idToken?.tokenString {
        promise(.success(NonEmptyString(rawValue: idToken)!))
      } else {
        promise(.failure(fromAWSError(error!)))
      }
    }
  }
  .eraseToAnyPublisher()
}

func publishableKeyRequest(auth token: NonEmptyString) -> URLRequest {
  let url = URL(string: "https://live-api.htprod.hypertrack.com/api-key")!
  var request = URLRequest(url: url)
  request.setValue(token.rawValue, forHTTPHeaderField: "Authorization")
  return request
}

func getPublishableKeyFuture(auth token: NonEmptyString) -> AnyPublisher<NonEmptyString, NonEmptyString> {
  URLSession.shared.dataTaskPublisher(for: publishableKeyRequest(auth: token))
  .map { data, _ in data }
  .decode(type: PublishableKeyResult.self, decoder: JSONDecoder())
  .mapError { NonEmptyString(rawValue: $0.localizedDescription)! }
  .tryMap { publishableKey in
    if let pk = NonEmptyString(rawValue: publishableKey.key) {
      return pk
    } else {
      throw failedToSignIn("KZEA3")
    }
  }
  .mapError { $0 as! NonEmptyString }
  .eraseToAnyPublisher()
}

// MARK: - Error Handling

let failedToSignIn = { NonEmptyString(rawValue: "Failed to sign in with error: " + $0)! }

extension AWSMobileClientError {
  var message: String {
    switch self {
      case let .aliasExists(message),
           let .badRequest(message),
           let .codeDeliveryFailure(message),
           let .codeMismatch(message),
           let .cognitoIdentityPoolNotConfigured(message),
           let .deviceNotRemembered(message),
           let .errorLoadingPage(message),
           let .expiredCode(message),
           let .expiredRefreshToken(message),
           let .federationProviderExists(message),
           let .groupExists(message),
           let .guestAccessNotAllowed(message),
           let .idTokenAndAcceessTokenNotIssued(message),
           let .idTokenNotIssued(message),
           let .identityIdUnavailable(message),
           let .internalError(message),
           let .invalidConfiguration(message),
           let .invalidLambdaResponse(message),
           let .invalidOAuthFlow(message),
           let .invalidParameter(message),
           let .invalidPassword(message),
           let .invalidState(message),
           let .invalidUserPoolConfiguration(message),
           let .limitExceeded(message),
           let .mfaMethodNotFound(message),
           let .notAuthorized(message),
           let .notSignedIn(message),
           let .passwordResetRequired(message),
           let .resourceNotFound(message),
           let .scopeDoesNotExist(message),
           let .securityFailed(message),
           let .softwareTokenMFANotFound(message),
           let .tooManyFailedAttempts(message),
           let .tooManyRequests(message),
           let .unableToSignIn(message),
           let .unexpectedLambda(message),
           let .unknown(message),
           let .userCancelledSignIn(message),
           let .userLambdaValidation(message),
           let .userNotConfirmed(message),
           let .userNotFound(message),
           let .userPoolNotConfigured(message),
           let .usernameExists(message):
        return message
    }
  }
}

func fromAWSError(_ error: Error) -> NonEmptyString {
  guard let error = error as? AWSMobileClientError else {
    return failedToSignIn("YAZ2V")
  }
  guard let nonEmptyError = NonEmptyString(rawValue: error.message) else {
    return failedToSignIn("xQwME")
  }
  return nonEmptyError
}
