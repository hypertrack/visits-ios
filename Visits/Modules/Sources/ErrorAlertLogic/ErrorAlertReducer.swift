import ComposableArchitecture
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
  case errorAlert(ErrorAlertAction)
  case historyUpdated(Result<History, APIError<Token.Expired>>)
  case orderCancelFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case orderCompleteFinished(Order, Result<Terminal, APIError<Token.Expired>>)
  case ordersUpdated(Result<Set<Order>, APIError<Token.Expired>>)
  case placesUpdated(Result<Set<Place>, APIError<Token.Expired>>)
  case signedIn(Result<PublishableKey, APIError<CognitoError>>)
  case tokenUpdated(Result<Token.Value, APIError<Never>>)
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
  case let .historyUpdated(.failure(.network(u))),
       let .orderCancelFinished(_, .failure(.network(u))),
       let .orderCompleteFinished(_, .failure(.network(u))),
       let .ordersUpdated(.failure(.network(u))),
       let .placesUpdated(.failure(.network(u))),
       let .signedIn(.failure(.network(u))),
       let .tokenUpdated(.failure(.network(u))):
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
       let .orderCancelFinished(_, .failure(.api(e, _, _))),
       let .orderCompleteFinished(_, .failure(.api(e, _, _))),
       let .ordersUpdated(.failure(.api(e, _, _))),
       let .placesUpdated(.failure(.api(e, _, _))),
       let .signedIn(.failure(.api(e, _, _))),
       let .tokenUpdated(.failure(.api(e, _, _))):
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
       let .orderCancelFinished(_, .failure(.server(e, _, _))),
       let .orderCompleteFinished(_, .failure(.server(e, _, _))),
       let .ordersUpdated(.failure(.server(e, _, _))),
       let .placesUpdated(.failure(.server(e, _, _))),
       let .signedIn(.failure(.server(e, _, _))),
       let .tokenUpdated(.failure(.server(e, _, _))):
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
       let .orderCancelFinished(_, .failure(.unknown(p, _, _))),
       let .orderCompleteFinished(_, .failure(.unknown(p, _, _))),
       let .ordersUpdated(.failure(.unknown(p, _, _))),
       let .placesUpdated(.failure(.unknown(p, _, _))),
       let .signedIn(.failure(.unknown(p, _, _))),
       let .tokenUpdated(.failure(.unknown(p, _, _))):
    guard state.visibility == .onScreen else { return .none }
    
    state.status = .shown(
      .init(
        title: TextState("Network Issue"),
        message: TextState("Data corrupted.\n\n\(p.string)\n\nOur engineers are notified about this issue."),
        dismissButton: dismissButton
      )
    )
    
    return .none
  case .historyUpdated(.success(_)),
       .orderCancelFinished(_, .success(_)),
       .orderCompleteFinished(_, .success(_)),
       .ordersUpdated(.success(_)),
       .placesUpdated(.success(_)),
       .signedIn(.success(_)),
       .tokenUpdated(.success(_)),
       .historyUpdated(.failure(.error(_, _, _))),
       .orderCancelFinished(_, .failure(.error(_, _, _))),
       .orderCompleteFinished(_, .failure(.error(_, _, _))),
       .ordersUpdated(.failure(.error(_, _, _))),
       .placesUpdated(.failure(.error(_, _, _))),
       .signedIn(.failure(.error(_, _, _))):
    return .none
  }
}

private let dismissButton = AlertState<ErrorAlertAction>.Button.default(TextState("OK"), send: .ok)
