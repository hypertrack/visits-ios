import AppArchitecture
import ComposableArchitecture
import NonEmpty
import Types
import Utility
import Validated


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
  case deepLinkFailed(NonEmptyArray<NonEmptyString>)
  case applyFullDeepLink(DeepLink, SDKStatusUpdate)
  case cancelAllRequests
  case refreshAllRequests
}

// MARK: - Environment

public struct DeepLinkEnvironment {
  public var handleDeepLink: (URL) -> Effect<Never, Never>
  public var makeSDK: (PublishableKey) -> Effect<SDKStatusUpdate, Never>
  public var setName: (Name) -> Effect<Never, Never>
  public var setMetadata: (JSON.Object) -> Effect<Never, Never>
  public var subscribeToDeepLinks: () -> Effect<Validated<DeepLink, NonEmptyString>, Never>
  
  public init(
    handleDeepLink: @escaping (URL) -> Effect<Never, Never>,
    makeSDK: @escaping (PublishableKey) -> Effect<SDKStatusUpdate, Never>,
    setName: @escaping (Name) -> Effect<Never, Never>,
    setMetadata: @escaping (JSON.Object) -> Effect<Never, Never>,
    subscribeToDeepLinks: @escaping () -> Effect<Validated<DeepLink, NonEmptyString>, Never>
  ) {
    self.handleDeepLink = handleDeepLink
    self.makeSDK = makeSDK
    self.setName = setName
    self.setMetadata = setMetadata
    self.subscribeToDeepLinks = subscribeToDeepLinks
  }
}

// MARK: - Reducer

public let deepLinkReducer = Reducer<DeepLinkState, DeepLinkAction, SystemEnvironment<DeepLinkEnvironment>> { state, action, environment in
  switch action {
  case .subscribeToDeepLinks:
    struct DeepLinkSubscription: Hashable {}
    
    let subscribe = environment.subscribeToDeepLinks()
      .flatMap { (validated: Validated<DeepLink, NonEmptyString>) -> Effect<DeepLinkAction, Never> in
        switch validated {
        case let .valid(deepLink):
          return environment.makeSDK(deepLink.publishableKey)
            .flatMap { (sdk: SDKStatusUpdate) -> Effect<DeepLinkAction, Never> in
              .merge(
                Effect(value: .applyFullDeepLink(deepLink, sdk)),
                environment.setName(deepLink.name).fireAndForget(),
                environment.setMetadata(deepLink.metadata).fireAndForget()
              )
            }
            .eraseToEffect()
        case let .invalid(errors):
          return Effect(value: DeepLinkAction.deepLinkFailed(errors))
        }
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
  case .deepLinkFailed:
    return .none
  case let .applyFullDeepLink(deepLink, sdk):
   
    state.flow = .main(
      .init(
        map: .initialState,
        orders: [],
        places: [],
        tab: .defaultTab,
        publishableKey: deepLink.publishableKey,
        profile: .init(name: deepLink.name, metadata: deepLink.metadata)
      )
    )
    state.sdk = sdk
    
    return .concatenate(
      Effect(value: .cancelAllRequests),
      Effect(value: .refreshAllRequests)
    )
  case .cancelAllRequests,
       .refreshAllRequests:
    return .none
  }
}

extension DeepLink {
  var name: Name {
    switch self.variant {
    case let .new(tEmailPhoneNumber, metadata):
      if case let .string(name) = metadata["name"], let nonEmptyName = NonEmptyString(rawValue: name) {
        return .init(rawValue: nonEmptyName)
      }
      return these(emailToName)(phoneNumberToName)(curry(emailAndPhoneNumberToName))(tEmailPhoneNumber)
    case let .old(driverID):
      return nonEmptyStringToName(driverID.rawValue)
    }
  }
  
  var metadata: JSON.Object {
    let inviteID = JSON.string(url.absoluteString)
    let emailKey = "email"
    let phoneKey = "phone_number"
    let inviteIDKey = "invite_id"

    switch self.variant {
    case .new(let tEmailPhoneNumber, var meta):
      switch tEmailPhoneNumber {
      case let .this(e):
        meta[emailKey] = .string(e.string)
      case let .that(p):
        meta[phoneKey] = .string(p.string)
      case let .both(e, p):
        meta[emailKey] = .string(e.string)
        meta[phoneKey] = .string(p.string)
      }
      meta[inviteIDKey] = inviteID
      return meta
    case let .old(driverID):
      return ["driver_id": .string(driverID.string), inviteIDKey: inviteID]
    }
  }
  
  func phoneNumberToName(_ phoneNumber: PhoneNumber) -> Name {
    .init(rawValue: phoneNumber.rawValue)
  }
  
  func emailAndPhoneNumberToName(_ email: Email, phoneNumber: PhoneNumber) -> Name {
    emailToName(email)
  }
}
