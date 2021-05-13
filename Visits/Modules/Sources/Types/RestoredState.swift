public struct RestoredState: Equatable {
  public var storage: StorageState
  public var version: AppVersion
  
  public init(storage: StorageState, version: AppVersion) {
    self.storage = storage; self.version = version
  }
}
