import ComposableArchitecture
import os

@available (iOS 14, *)
let loggerAction = Logger(subsystem: "com.hypertrack.visits", category: "Action")
@available (iOS 14, *)
let loggerEffect = Logger(subsystem: "com.hypertrack.visits", category: "Effect")

public func logEffect(_ message: String) {
  #if DEBUG
    if #available(iOS 14, *) {
      loggerEffect.log("🚀 \(message)")
    }
  #endif
}

public func logAction(_ message: String) {
  #if DEBUG
    if #available(iOS 14, *) {
      loggerAction.log("🚀 \(message)")
    }
  #endif
}

public func logEffect<E>(_ message: String, failureType: E.Type) -> Effect<Void, E> {
  .result {
    logEffect(message)
    return .success(())
  }
}
