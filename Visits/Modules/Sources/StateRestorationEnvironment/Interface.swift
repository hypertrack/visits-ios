import ComposableArchitecture
import Types
import NonEmpty


public struct StateRestorationEnvironment {
  public var loadState: (NonEmptyString?) -> Effect<Result<StorageState?, StateRestorationError>, Never>
  public var saveState: (StorageState) -> Effect<Never, Never>
  
  public init(
    loadState: @escaping (NonEmptyString?) -> Effect<Result<StorageState?, StateRestorationError>, Never>,
    saveState: @escaping (StorageState) -> Effect<Never, Never>
  ) {
    self.loadState = loadState
    self.saveState = saveState
  }
}

