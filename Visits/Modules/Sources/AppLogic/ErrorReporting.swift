import AppArchitecture
import ComposableArchitecture
import ErrorReportingEnvironment
import NonEmpty
import Utility
import Tagged
import Types


extension Reducer where State == AppState, Action == AppAction, Environment == SystemEnvironment<AppEnvironment> {
  func reportErrors() -> Reducer {
    .init { state, action, environment in
      let previousState = state
      let globalEffects = self.run(&state, action, environment)
      let nextState = state
      
      let report = environment.errorReporting
      
      var effects: [Effect<AppAction, Never>] = []
      
      func run(_ e: Effect<Never, Never>) {
        effects += [e.fireAndForget()]
      }
      
      if case .osFinishedLaunching = action {
        run(report.startErrorMonitoring())
      }
      
      switch (deviceID(from: previousState), deviceID(from: nextState)) {
      case let (.none, .some(deID)):
        run(report.updateUser(deID))
      case let (.some(deIDB), .some(deIDA)) where deIDB != deIDA:
        run(report.updateUser(deIDA))
      default:
        break
      }
      
      func debugPrint(action: AppAction, previousState: AppState, nextState: AppState) -> Effect<(String, String?), Never> {
        .future { callback in
          let actionOutput = debugOutput(action)
          let stateOutput = debugDiff(previousState, nextState).map { "\($0)\n" }
          callback(.success((actionOutput, stateOutput)))
        }
      }
      
      run(
        debugPrint(action: action, previousState: previousState, nextState: nextState)
          .flatMap{ (action: String, state: String?) -> Effect<Never, Never> in
            let actionBreadcrumb =  NonEmptyString.init(rawValue: action)
            let stateBreadcrumb = state >>- NonEmptyString.init(rawValue:)
            
            switch (actionBreadcrumb, stateBreadcrumb) {
            case let (.some(a), .some(s)):
              return .concatenate(
                report.addBreadcrumb(.action, .init(rawValue: a)),
                report.addBreadcrumb(.state, .init(rawValue: s))
              )
            case let (.some(a), .none):
              return report.addBreadcrumb(.action, .init(rawValue: a))
            case let (.none, .some(s)):
              return report.addBreadcrumb(.state, .init(rawValue: s))
            case (.none, .none):
              return .none
            }
          }
          .subscribe(on: environment.backgroundQueue)
          .receive(on: environment.mainQueue)
          .eraseToEffect()
      )
      
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
      case let .tokenUpdated(.failure(e)):             error = e
      case let .signedIn(.failure(e)):                 error = toNever(e)
      case let .ordersUpdated(.failure(e)),
           let .placesUpdated(.failure(e)),
           let .profileUpdated(.failure(e)),
           let .historyUpdated(.failure(e)):           error = toNever(e)
      case let .orderCancelFinished(_, .failure(e)),
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
      
      return .merge(globalEffects, .concatenate(effects))
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

extension Tagged: CustomDebugOutputConvertible where RawValue: CustomDebugOutputConvertible {
  public var debugOutput: String {
    rawValue.debugOutput
  }
}

extension NonEmpty: CustomDebugOutputConvertible where Collection: CustomDebugOutputConvertible {
  public var debugOutput: String {
    rawValue.debugOutput
  }
}

extension String: CustomDebugOutputConvertible {
  public var debugOutput: String { self }
}

extension UInt: CustomDebugOutputConvertible {
  public var debugOutput: String { self.description }
}

extension Coordinate: CustomDebugOutputConvertible {
  public var debugOutput: String { String(format: "%.6f", latitude) + " " + String(format: "%.6f", longitude) }
}

private func debugOutput(_ value: Any, indent: Int = 0) -> String {
  var visitedItems: Set<ObjectIdentifier> = []

  func debugOutputHelp(_ value: Any, indent: Int = 0) -> String {
    let mirror = Mirror(reflecting: value)
    switch (value, mirror.displayStyle) {
    case let (value as CustomDebugOutputConvertible, _):
      return value.debugOutput.indent(by: indent)
    case (_, .collection?):
      return """
        [
        \(mirror.children.map { "\(debugOutput($0.value, indent: 2)),\n" }.joined())]
        """
        .indent(by: indent)

    case (_, .dictionary?):
      let pairs = mirror.children.map { label, value -> String in
        let pair = value as! (key: AnyHashable, value: Any)
        return
          "\("\(debugOutputHelp(pair.key.base)): \(debugOutputHelp(pair.value)),".indent(by: 2))\n"
      }
      return """
        [
        \(pairs.sorted().joined())]
        """
        .indent(by: indent)

    case (_, .set?):
      return """
        Set([
        \(mirror.children.map { "\(debugOutputHelp($0.value, indent: 2)),\n" }.sorted().joined())])
        """
        .indent(by: indent)

    case (_, .optional?):
      return mirror.children.isEmpty
        ? "nil".indent(by: indent)
        : debugOutputHelp(mirror.children.first!.value, indent: indent)

    case (_, .enum?) where !mirror.children.isEmpty:
      let child = mirror.children.first!
      let childMirror = Mirror(reflecting: child.value)
      let elements =
        childMirror.displayStyle != .tuple
        ? debugOutputHelp(child.value, indent: 2)
        : childMirror.children.map { child -> String in
          let label = child.label!
          return "\(label.hasPrefix(".") ? "" : "\(label): ")\(debugOutputHelp(child.value))"
        }
        .joined(separator: ",\n")
        .indent(by: 2)
      return """
        \(mirror.subjectType).\(child.label!)(
        \(elements)
        )
        """
        .indent(by: indent)

    case (_, .enum?):
      return """
        \(mirror.subjectType).\(value)
        """
        .indent(by: indent)

    case (_, .struct?) where !mirror.children.isEmpty:
      let elements = mirror.children
        .map { "\($0.label.map { "\($0): " } ?? "")\(debugOutputHelp($0.value))".indent(by: 2) }
        .joined(separator: ",\n")
      return """
        \(mirror.subjectType)(
        \(elements)
        )
        """
        .indent(by: indent)

    case let (value as AnyObject, .class?)
    where !mirror.children.isEmpty && !visitedItems.contains(ObjectIdentifier(value)):
      visitedItems.insert(ObjectIdentifier(value))
      let elements = mirror.children
        .map { "\($0.label.map { "\($0): " } ?? "")\(debugOutputHelp($0.value))".indent(by: 2) }
        .joined(separator: ",\n")
      return """
        \(mirror.subjectType)(
        \(elements)
        )
        """
        .indent(by: indent)

    case let (value as AnyObject, .class?)
    where !mirror.children.isEmpty && visitedItems.contains(ObjectIdentifier(value)):
      return "\(mirror.subjectType)(↩︎)"

    case let (value as CustomStringConvertible, .class?):
      return value.description
        .replacingOccurrences(
          of: #"^<([^:]+): 0x[^>]+>$"#, with: "$1()", options: .regularExpression
        )
        .indent(by: indent)

    case let (value as CustomDebugStringConvertible, _):
      return value.debugDescription
        .replacingOccurrences(
          of: #"^<([^:]+): 0x[^>]+>$"#, with: "$1()", options: .regularExpression
        )
        .indent(by: indent)

    case let (value as CustomStringConvertible, _):
      return value.description
        .indent(by: indent)

    case (_, .struct?), (_, .class?):
      return "\(mirror.subjectType)()"
        .indent(by: indent)

    case (_, .tuple?) where mirror.children.isEmpty:
      return "()"
        .indent(by: indent)

    case (_, .tuple?):
      let elements = mirror.children.map { child -> String in
        let label = child.label!
        return "\(label.hasPrefix(".") ? "" : "\(label): ")\(debugOutputHelp(child.value))"
          .indent(by: 2)
      }
      return """
        (
        \(elements.joined(separator: ",\n"))
        )
        """
        .indent(by: indent)

    case (_, nil):
      return "\(value)"
        .indent(by: indent)

    @unknown default:
      return "\(value)"
        .indent(by: indent)
    }
  }

  return debugOutputHelp(value, indent: indent)
}

private extension String {
  func indent(by indent: Int) -> String {
    let indentation = String(repeating: " ", count: indent)
    return indentation + self.replacingOccurrences(of: "\n", with: "\n\(indentation)")
  }
}

private func debugDiff<T>(_ before: T, _ after: T, printer: (T) -> String = { debugOutput($0) }) -> String? {
  diff(printer(before), printer(after))
}

private func diff(_ first: String, _ second: String) -> String? {
  struct Difference {
    enum Which {
      case both
      case first
      case second

      var prefix: StaticString {
        switch self {
        case .both: return "\u{2007}"
        case .first: return "−"
        case .second: return "+"
        }
      }
    }

    let elements: ArraySlice<Substring>
    let which: Which
  }

  func diffHelp(_ first: ArraySlice<Substring>, _ second: ArraySlice<Substring>) -> [Difference] {
    var indicesForLine: [Substring: [Int]] = [:]
    for (firstIndex, firstLine) in zip(first.indices, first) {
      indicesForLine[firstLine, default: []].append(firstIndex)
    }

    var overlap: [Int: Int] = [:]
    var firstIndex = first.startIndex
    var secondIndex = second.startIndex
    var count = 0

    for (index, secondLine) in zip(second.indices, second) {
      var innerOverlap: [Int: Int] = [:]
      var innerFirstIndex = firstIndex
      var innerSecondIndex = secondIndex
      var innerCount = count

      indicesForLine[secondLine]?.forEach { firstIndex in
        let newCount = (overlap[firstIndex - 1] ?? 0) + 1
        innerOverlap[firstIndex] = newCount
        if newCount > count {
          innerFirstIndex = firstIndex - newCount + 1
          innerSecondIndex = index - newCount + 1
          innerCount = newCount
        }
      }

      overlap = innerOverlap
      firstIndex = innerFirstIndex
      secondIndex = innerSecondIndex
      count = innerCount
    }

    if count == 0 {
      var differences: [Difference] = []
      if !first.isEmpty { differences.append(Difference(elements: first, which: .first)) }
      if !second.isEmpty { differences.append(Difference(elements: second, which: .second)) }
      return differences
    } else {
      var differences = diffHelp(first.prefix(upTo: firstIndex), second.prefix(upTo: secondIndex))
      differences.append(
        Difference(elements: first.suffix(from: firstIndex).prefix(count), which: .both))
      differences.append(
        contentsOf: diffHelp(
          first.suffix(from: firstIndex + count), second.suffix(from: secondIndex + count)))
      return differences
    }
  }

  let differences = diffHelp(
    first.split(separator: "\n", omittingEmptySubsequences: false)[...],
    second.split(separator: "\n", omittingEmptySubsequences: false)[...]
  )
  if differences.count == 1, case .both = differences[0].which { return nil }
  var string = differences.reduce(into: "") { string, diff in
    diff.elements.forEach { line in
      string += "\(diff.which.prefix) \(line)\n"
    }
  }
  string.removeLast()
  return string
}
