import ComposableArchitecture
import NonEmpty
import Tagged
import Types


public extension StateRestorationEnvironment {
  static func mock(initialState: StorageState?) -> Self {
    var state = initialState
    
    return Self(
      loadState: {
        print("Loading state:\n\(debugOutput(state as Any))")
        
        return Effect(value: .success(state))
      },
      saveState: { storateState in
        print("Saving state:\n\(debugOutput(state as Any))")
        
        state = storateState

        return .none
      }
    )
  }
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
