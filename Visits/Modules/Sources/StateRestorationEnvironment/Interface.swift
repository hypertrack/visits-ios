import ComposableArchitecture
import Types


public struct StateRestorationEnvironment {
  public var loadState: () -> Effect<Result<StorageState?, StateRestorationError>, Never>
  public var saveState: (StorageState) -> Effect<Never, Never>
  
  public init(
    loadState: @escaping () -> Effect<Result<StorageState?, StateRestorationError>, Never>,
    saveState: @escaping (StorageState) -> Effect<Never, Never>
  ) {
    self.loadState = loadState
    self.saveState = saveState
  }
}

