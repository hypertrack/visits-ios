import ComposableArchitecture
import Combine
import Prelude

// MARK: - State

public enum DriverIDState: Equatable {
  case ready(Ready)
  case empty
  
  public static let initialState = DriverIDState.empty
}

public struct Ready: Equatable {
  var driverID: NonEmptyString
  var inProgress: Bool
  
  public static func ready(for driverID: NonEmptyString) -> Ready {
    return .init(driverID: driverID, inProgress: false)
  }
}

// MARK: - Action

public enum DriverIDAction: Equatable {
  case driverIDChanged(String)
  case register(driverID: NonEmptyString)
  case tryToRegister
}

// MARK: - Reducer

public let driverIDReducer = Reducer<DriverIDState, DriverIDAction, Void> { state, action, _ in
  switch action {
  case let .driverIDChanged(driverID):
    let cleaned = NonEmptyString(rawValue: driverID.clean())
    switch (state, cleaned) {
    case (.empty, .none):
      return .none
    case let (.empty, .some(id)):
      state = .ready(.ready(for: id))
      return .none
    case (.ready, .none):
      state = .empty
      return .none
    case let (.ready, .some(id)):
      state = state |> /DriverIDState.ready >>> \.driverID %- const(id)
      return .none
    }
  case .register:
    return .none
  case .tryToRegister:
    if case let .ready(ready) = state {
      state = .ready(ready |> (\Ready.inProgress) .~ true)
      return Effect(value: DriverIDAction.register(driverID: ready.driverID))
    }
    return .none
  }
}
