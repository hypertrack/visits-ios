import ComposableArchitecture
import NonEmpty
import Tagged
import Types
import Utility


// MARK: - State

public struct ErrorAlertState: Equatable {
  public enum Status: Equatable {
    case dismissed
    case shown(AlertState<ErrorAlertAction>)
  }
  
  public var status: Status
  public var visibility: AppVisibility
  
  public init(status: Status, visibility: AppVisibility) {
    self.status = status; self.visibility = visibility
  }
}

// MARK: - Action

public enum ErrorAlertLogicAction: Equatable {
  case appVisibilityChanged(AppVisibility)
  case deepLinkFailed(NonEmptyArray<NonEmptyString>)
  case errorAlert(ErrorAlertAction)
  case historyUpdated(Result<History, APIError<Token.Expired>>)
  case integrationEntitiesUpdatedWithFailure(APIError<Token.Expired>)
  case orderCancelFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderCompleteFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderSnoozeFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderUnsnoozeFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case tripUpdated(Result<Trip?, APIError<Token.Expired>>)
  case placesUpdated(Result<PlacesSummary, APIError<Token.Expired>>)
  case placeCreatedWithFailure(APIError<Token.Expired>)
  case profileUpdated(Result<Profile, APIError<Token.Expired>>)
  case signedIn(Result<PublishableKey, APIError<CognitoError>>)
  case teamUpdated(Result<TeamValue?, APIError<Token.Expired>>)
  case tokenUpdated(Result<Token.Value, APIError<Never>>)
  case visitsUpdated(Result<PlacesVisitsSummary, APIError<Token.Expired>>)
}

// MARK: - Reducer

public let errorAlertReducer = Reducer<ErrorAlertState, ErrorAlertLogicAction, Void> { state, action, environment in
  let tryAgain = "\nPlease try again"
  switch action {
  case .appVisibilityChanged(.offScreen), .errorAlert(.ok):
    
    state.status = .dismissed
    
    return .none
  case .appVisibilityChanged(.onScreen):
    return .none
  case let .deepLinkFailed(e):
    if e.contains(where: { $0.rawValue.hasPrefix("Branch error") }) {
      state.status = .shown(
        .init(
          title: TextState("Deep link failed"),
          message: TextState("We couldn't contact our deep link server" + tryAgain),
          dismissButton: dismissButton
        )
      )
    } else {
      state.status = .shown(
        .init(
          title: TextState("Deep link failed"),
          message: TextState("We couldn't recognize this deep link, the app may be outdated or there is an issue with the link.\n\nPlease contact HyperTrack for help at help@hypertrack.com"),
          dismissButton: dismissButton
        )
      )
    }

    return .none
  case let .historyUpdated(.failure(.network(u))),
       let .integrationEntitiesUpdatedWithFailure(.network(u)),
       let .orderCancelFinished(_, .failure(.network(u))),
       let .orderCompleteFinished(_, .failure(.network(u))),
       let .orderSnoozeFinished(_, .failure(.network(u))),
       let .orderUnsnoozeFinished(_, .failure(.network(u))),
       let .tripUpdated(.failure(.network(u))),
       let .placeCreatedWithFailure(.network(u)),
       let .placesUpdated(.failure(.network(u))),
       let .profileUpdated(.failure(.network(u))),
       let .signedIn(.failure(.network(u))),
       let .teamUpdated(.failure(.network(u))),
       let .tokenUpdated(.failure(.network(u))),
       let .visitsUpdated(.failure(.network(u))):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState(u.errorDescription.rawValue + tryAgain),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case let .historyUpdated(.failure(.api(e, _, _))),
       let .integrationEntitiesUpdatedWithFailure(.api(e, _, _)),
       let .orderCancelFinished(_, .failure(.api(e, _, _))),
       let .orderCompleteFinished(_, .failure(.api(e, _, _))),
       let .orderSnoozeFinished(_, .failure(.api(e, _, _))),
       let .orderUnsnoozeFinished(_, .failure(.api(e, _, _))),
       let .tripUpdated(.failure(.api(e, _, _))),
       let .placeCreatedWithFailure(.api(e, _, _)),
       let .placesUpdated(.failure(.api(e, _, _))),
       let .profileUpdated(.failure(.api(e, _, _))),
       let .signedIn(.failure(.api(e, _, _))),
       let .teamUpdated(.failure(.api(e, _, _))),
       let .tokenUpdated(.failure(.api(e, _, _))),
       let .visitsUpdated(.failure(.api(e, _, _))):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState(e.title.string),
        message: TextState(e.detail.string),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case let .historyUpdated(.failure(.server(e, _, _))),
       let .integrationEntitiesUpdatedWithFailure(.server(e, _, _)),
       let .orderCancelFinished(_, .failure(.server(e, _, _))),
       let .orderCompleteFinished(_, .failure(.server(e, _, _))),
       let .orderSnoozeFinished(_, .failure(.server(e, _, _))),
       let .orderUnsnoozeFinished(_, .failure(.server(e, _, _))),
       let .tripUpdated(.failure(.server(e, _, _))),
       let .placeCreatedWithFailure(.server(e, _, _)),
       let .placesUpdated(.failure(.server(e, _, _))),
       let .profileUpdated(.failure(.server(e, _, _))),
       let .signedIn(.failure(.server(e, _, _))),
       let .teamUpdated(.failure(.server(e, _, _))),
       let .tokenUpdated(.failure(.server(e, _, _))),
       let .visitsUpdated(.failure(.server(e, _, _))):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState("Server Error"),
        message: TextState(e.message.rawValue + tryAgain),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case let .historyUpdated(.failure(.unknown(p, _, _))),
       let .integrationEntitiesUpdatedWithFailure(.unknown(p, _, _)),
       let .orderCancelFinished(_, .failure(.unknown(p, _, _))),
       let .orderCompleteFinished(_, .failure(.unknown(p, _, _))),
       let .orderSnoozeFinished(_, .failure(.unknown(p, _, _))),
       let .orderUnsnoozeFinished(_, .failure(.unknown(p, _, _))),
       let .tripUpdated(.failure(.unknown(p, _, _))),
       let .placeCreatedWithFailure(.unknown(p, _, _)),
       let .placesUpdated(.failure(.unknown(p, _, _))),
       let .profileUpdated(.failure(.unknown(p, _, _))),
       let .signedIn(.failure(.unknown(p, _, _))),
       let .teamUpdated(.failure(.unknown(p, _, _))),
       let .tokenUpdated(.failure(.unknown(p, _, _))),
       let .visitsUpdated(.failure(.unknown(p, _, _))):
    guard state.visibility == .onScreen else { return .none }

    guard !p.string.hasPrefix("Received unexpected status code 404") else { return .none }

    state.status = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState("Data corrupted.\n\n\(p.string)\n\nOur engineers are notified about this issue."),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case .historyUpdated(.failure(.error)),
       .historyUpdated(.success),
       .integrationEntitiesUpdatedWithFailure(.error),
       .orderCancelFinished(_, .failure(.error)),
       .orderCancelFinished(_, .success),
       .orderCompleteFinished(_, .failure(.error)),
       .orderCompleteFinished(_, .success),
       .orderSnoozeFinished(_, .failure(.error)),
       .orderSnoozeFinished(_, .success),
       .orderUnsnoozeFinished(_, .failure(.error)),
       .orderUnsnoozeFinished(_, .success),
       .tripUpdated(.failure(.error)),
       .tripUpdated(.success),
       .placeCreatedWithFailure(.error),
       .placesUpdated(.failure(.error)),
       .placesUpdated(.success),
       .profileUpdated(.failure(.error)),
       .profileUpdated(.success),
       .signedIn(.failure(.error)),
       .signedIn(.success),
       .teamUpdated(.failure(.error)),
       .teamUpdated(.success),
       .tokenUpdated(.success),
       .visitsUpdated(.success),
       .visitsUpdated(.failure(.error(_, _, _))):
    return .none
  }
}

private let dismissButton = AlertState<ErrorAlertAction>.Button.default(TextState("OK"), action: .send(.ok))
