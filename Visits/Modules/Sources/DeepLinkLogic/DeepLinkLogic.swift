import AppArchitecture
import ComposableArchitecture
import Utility
import Types


// MARK: - State

public struct DeepLinkState: Equatable {
  public var flow: AppFlow
  public var sdk: SDKStatusUpdate
  
  public init(flow: AppFlow, sdk: SDKStatusUpdate) {
    self.flow = flow
    self.sdk = sdk
  }
}

// MARK: - Action

public enum DeepLinkAction: Equatable {
  case subscribeToDeepLinks
  case firstRunWaitingComplete
  case deepLinkOpened(URL)
  case applyFullDeepLink(PublishableKey, DriverID, SDKStatusUpdate)
  case applyPartialDeepLink(PublishableKey)
}

// MARK: - Environment

public struct DeepLinkEnvironment {
  public var handleDeepLink: (URL) -> Effect<Never, Never>
  public var makeSDK: (PublishableKey) -> Effect<SDKStatusUpdate, Never>
  public var setDriverID: (DriverID) -> Effect<Never, Never>
  public var subscribeToDeepLinks: () -> Effect<(PublishableKey, DriverID?), Never>
  
  public init(
    handleDeepLink: @escaping (URL) -> Effect<Never, Never>,
    makeSDK: @escaping (PublishableKey) -> Effect<SDKStatusUpdate, Never>,
    setDriverID: @escaping (DriverID) -> Effect<Never, Never>,
    subscribeToDeepLinks: @escaping () -> Effect<(PublishableKey, DriverID?), Never>
  ) {
    self.handleDeepLink = handleDeepLink
    self.makeSDK = makeSDK
    self.setDriverID = setDriverID
    self.subscribeToDeepLinks = subscribeToDeepLinks
  }
}

// MARK: - Reducer

public let deepLinkReducer = Reducer<DeepLinkState, DeepLinkAction, SystemEnvironment<DeepLinkEnvironment>> { state, action, environment in
  switch action {
  case .subscribeToDeepLinks:
    struct DeepLinkSubscription: Hashable {}
    
    let subscribe = environment.subscribeToDeepLinks()
      .flatMap { (pk: PublishableKey, drID: DriverID?) -> Effect<DeepLinkAction, Never> in
        guard let drID = drID else {
          return Effect(value: .applyPartialDeepLink(pk))
        }
        return environment.makeSDK(pk)
          .flatMap { (sdk: SDKStatusUpdate) -> Effect<DeepLinkAction, Never> in
            .merge(
              Effect(value: .applyFullDeepLink(pk, drID, sdk)),
              environment.setDriverID(drID).fireAndForget()
            )
          }
          .eraseToEffect()
      }
      .receive(on: environment.mainQueue)
      .eraseToEffect()
      .cancellable(id: DeepLinkSubscription(), cancelInFlight: true)
    
    if state.flow == .firstRun {
      return .merge(
        Effect(value: .firstRunWaitingComplete)
          .delay(for: .seconds(3), scheduler: environment.mainQueue)
          .eraseToEffect(),
        subscribe
      )
    } else {
      return subscribe
    }
  case .firstRunWaitingComplete:
    guard state.flow == .firstRun else { return .none }
    
    state.flow = .firstScreen
    
    return .none
  case let .deepLinkOpened(url):
    
    return environment.handleDeepLink(url).fireAndForget()
  
  case let .applyFullDeepLink(pk, drID, sdk):
   
    state.flow = .main(.init(map: .initialState, orders: [], places: [], tab: .defaultTab, publishableKey: pk, driverID: drID, refreshing: .none))
    state.sdk = sdk
    
    return .none
  case let .applyPartialDeepLink(pk):
    
    state.flow = .driverID(.init(status: .entering(nil), publishableKey: pk))
    
    return .none
  }
}
