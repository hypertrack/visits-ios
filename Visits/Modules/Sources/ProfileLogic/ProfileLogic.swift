import ComposableArchitecture
import Types


// MARK: - Action

public enum ProfileAction: Equatable {
  case profileUpdated(Profile)
}

// MARK: - Reducer

public let profileReducer = Reducer<Profile, ProfileAction, Void> { state, action, _ in
  switch action {
  case let .profileUpdated(p):
    state = p
    
    return .none
  }
}
