import ComposableArchitecture
import Types


// MARK: - Action

public enum AutoSavingAction: Equatable {
  case save(StorageState)
}

// MARK: - Environment

public struct AutoSavingEnvironment {
  public var saveState: (StorageState) -> Effect<Never, Never>
  
  public init(saveState: @escaping (StorageState) -> Effect<Never, Never>) {
    self.saveState = saveState
  }
}


// MARK: - Reducer

public let autoSavingReducer = Reducer<Void, AutoSavingAction, AutoSavingEnvironment> { _, action, environment in
  switch action {
  case let .save(ss): return environment.saveState(ss).fireAndForget()
  }
}
