import ComposableArchitecture
import os


let loggerAction = Logger(subsystem: "com.hypertrack.visits", category: "Action")
let loggerEffect = Logger(subsystem: "com.hypertrack.visits", category: "Effect")

public func logEffect(_ message: String) {
  #if DEBUG
    loggerEffect.log("🚀 \(message)")
  #endif
}

public func logAction(_ message: String) {
  #if DEBUG
    logInChunks({ loggerAction.log("\($0)") }, message: "🚀 " + message)
  #endif
}

public func logEffect<E>(_ message: String, failureType: E.Type) -> Effect<Void, E> {
  .result {
    logEffect(message)
    return .success(())
  }
}


func logInChunks(_ log: (String) -> Void, message: String) {
  // Circumventing 1024 byte storage limit for dynamic content in os_log
  let bytes: [UInt8] = message.utf8.map { UInt8($0) }
  // Value below proved to work without truncation while running without a
  // debugger attached (with debugger value of 1024 worked correctly)
  let chunkSize = 900

  if bytes.count > chunkSize {
    let kibibyteChunks = stride(from: 0, to: bytes.count, by: chunkSize).map {
      Array(bytes[$0 ..< min($0 + chunkSize, bytes.count)])
    }
    let stringChunks = kibibyteChunks
      .compactMap { String(data: Data($0), encoding: .utf8) }
    for chunk in stringChunks {
      log(chunk)
    }
  } else {
    log(message)
  }
}
