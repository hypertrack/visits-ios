import ComposableArchitecture
import CustomDump
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

private func debugOutput<T>(_ value: T) -> String {
  var out = ""
  customDump(value, to: &out)
  return out
}
