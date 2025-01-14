import AppArchitecture
import ComposableArchitecture
import CustomDump
import ErrorReportingEnvironment
import NonEmpty
import Utility
import Tagged
import Types


extension Reducer where State == AppState, Action == AppAction, Environment == SystemEnvironment<AppEnvironment> {
  func reportErrors() -> Reducer {
    .init { state, action, environment in
      let report = environment.errorReporting
      
      var effects: [Effect<AppAction, Never>] = []
      
      func run(_ e: Effect<Never, Never>) {
        effects += [e.fireAndForget()]
      }
      
      if case .osFinishedLaunching = action {
        run(report.startErrorMonitoring())
      }
      
      func addAsyncBreadcrumb(_ type: BreadcrumbType, _ f: @escaping @autoclosure () -> String?) -> Effect<Never, Never> {
        Effect<String?, Never>.future { callback in
          callback(.success(f()))
        }
        .compactMap(identity)
        .compactMap(NonEmptyString.init(rawValue:))
        .map(BreadcrumbMessage.init(rawValue:))
        .subscribe(on: environment.backgroundQueue)
        .receive(on: environment.mainQueue)
        .flatMap(type |> curry(report.addBreadcrumb))
        .eraseToEffect()
      }
      
      run(addAsyncBreadcrumb(.action, debugOutput(action)))
      
      let previousState = state
      let globalEffects = self.run(&state, action, environment)
      let nextState = state
      
      switch (deviceID(from: previousState), deviceID(from: nextState)) {
      case let (.none, .some(deID)):
        run(report.updateUser(deID))
      case let (.some(deIDB), .some(deIDA)) where deIDB != deIDA:
        run(report.updateUser(deIDA))
      default:
        break
      }
      
      run(addAsyncBreadcrumb(.state, diff(previousState, nextState)))
      
      func isNotAboutInternetConnection(_ e: APIError<Never>) -> Bool {
        if case let .network(urlError) = e {
          switch urlError.code {
          case .notConnectedToInternet,
               .timedOut,
               .networkConnectionLost,
               .callIsActive,
               .internationalRoamingOff,
               .dataNotAllowed,
               .cancelled,
               .cannotConnectToHost,
               .cannotFindHost,
               .dnsLookupFailed,
               .userCancelledAuthentication:
            return false
          default:
            return true
          }
        } else {
          return true
        }
      }
      
      let error: APIError<Never>?
      switch action {
      case let .profileUpdated(.failure(.unknown(p, _, _))) where p.string.hasPrefix("Received unexpected status code 404"): error = nil
      case let .tokenUpdated(.failure(e)):             error = e
      case let .signedIn(.failure(e)):                 error = toNever(e)
      case let .integrationEntitiesUpdatedWithFailure(e),
           let .tripUpdated(.failure(e)),
           let .placesUpdated(.failure(e)),
           let .placeCreatedWithFailure(e),
           let .profileUpdated(.failure(e)),
           let .historyUpdated(.failure(e)),
           let .teamUpdated(.failure(e)),
           let .visitsUpdated(.failure(e)),
           let .orderCancelFinished(_, .failure(e)),
           let .orderSnoozeFinished(_, .failure(e)),
           let .orderUnsnoozeFinished(_, .failure(e)),
           let .orderCompleteFinished(_, .failure(e)): error = toNever(e)
      default:                                         error = nil
      }
      if let error = error, isNotAboutInternetConnection(error) {
        run(report.capture(.init(rawValue: errorMessage(from: error))))
      }
      
      if case let .restoredState(_, _, .some(e)) = action {
        run(report.capture(.init(rawValue: .init(rawValue: debugOutput(e))!)))
      }
      
      if case let .deepLinkFailed(errors) = action {
        run(report.capture(.init(rawValue: "Deep Link Failed:\n* \(errors.joined(separator: "\n* "))")))
      }
      
      if action == .errorReportingAlert(.yes) {
        run(report.capture(.init(rawValue: "Manual Report \(environment.uuid().uuidString)")))
      }
      
      return .merge(
        globalEffects,
        .concatenate(effects)
      )
    }
  }
}

private func deviceID(from s: AppState) -> DeviceID? {
  switch s {
  case let .operational(o):
    switch o.sdk.status {
    case let .unlocked(deID, _):
      return deID
    case .locked:
      return nil
    }
  default:
    return nil
  }
}

private func errorMessage(from error: APIError<Never>) -> NonEmptyString {
  switch error {
  case let .api(e, r, d):
    return e.detail.rawValue + "\n" + r.prettyPrinted + "\n" + d.prettyPrintedJSON
  case let .server(e, r, d):
    return e.message + "\n" + r.prettyPrinted + "\n" + d.prettyPrintedJSON
  case let .network(e):
    return e.prettyPrinted
  case let .unknown(p, r, d):
    return p.string + "\n" + r.prettyPrinted + "\n" + d.prettyPrintedJSON
  }
}

extension Tagged: CustomDumpStringConvertible where RawValue: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    rawValue.customDumpDescription
  }
}

extension NonEmpty: CustomDumpStringConvertible where Collection: CustomDumpStringConvertible {
  public var customDumpDescription: String {
    rawValue.customDumpDescription
  }
}

extension String: CustomDumpStringConvertible {
  public var customDumpDescription: String { self }
}

extension UInt: CustomDumpStringConvertible {
  public var customDumpDescription: String { self.description }
}

extension Coordinate: CustomDumpStringConvertible {
  public var customDumpDescription: String { String(format: "%.6f", latitude) + " " + String(format: "%.6f", longitude) }
}

private func debugOutput<T>(_ value: T) -> String {
  var out = ""
  customDump(value, to: &out)
  return out
}
