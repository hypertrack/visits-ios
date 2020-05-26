import SwiftUI
import ViewsComponents
import ComposableArchitecture
import Combine
import Prelude
import HyperTrack

// MARK: - Environment

public typealias DeliveriesEnvironment = (
  getDeliveries: (_ publishableKey: NonEmptyString, _ deviceID: NonEmptyString) -> Effect<DeliveriesListOrErrorString, Never>,
  deliveriesDismissTimer: (_ scheduler: AnySchedulerOf<DispatchQueue>) -> Effect<Void, Never>
)

public let live = DeliveriesEnvironment(getDeliveries: getDeliveries, deliveriesDismissTimer: deliveriesDismissTimer)

public let mock = DeliveriesEnvironment(
  getDeliveries: { publishableKey, deviceID in
    return Just(mockDeliveryList())
      .delay(for: .seconds(5), scheduler: DispatchQueue.main)
      .eraseToEffect()
},
  deliveriesDismissTimer: deliveriesDismissTimer
)

func mockDeliveryList() -> DeliveriesListOrErrorString {
  return .left([
    DeliveryModel(
      id: "2c1f2901-c5a5-43f6-a29e-33e58ca9a19e",
      createdAt: "2020-01-16T15:27:26.586384+00:00".iso8601!,
      lat: 48.230319,
      lng: 16.376480,
      shortAddress: "Rauscherstraße 5",
      fullAddress: "Rauscherstraße 5, 1200 Wien, Австрия",
      metadata: [DeliveryModel.Metadata(key: "testKey", value: "testValue")]
    )
  ])
}

// MARK: - State

public struct DeliveriesState: Equatable {
  public init(publishableKey: NonEmptyString, deliveries: [DeliveryModel], networkStatus: NetworkStatus, isTracking: Bool) {
    self.publishableKey = publishableKey
    self.deliveries = deliveries
    self.networkStatus = networkStatus
    self.isTracking = isTracking
  }
  
  public let publishableKey: NonEmptyString
  public var deliveries: [DeliveryModel]
  public var networkStatus: NetworkStatus
  public var isTracking: Bool
  
  public static func initialState(publishableKey: NonEmptyString) -> DeliveriesState {
    DeliveriesState(publishableKey: publishableKey,
                    deliveries: [],
                    networkStatus: .online(.notSent),
                    isTracking: false)
  }
}

public enum NetworkStatus: Equatable {
  case online(RequestStatus)
  case offline
}

public enum RequestStatus: Equatable {
  case inFlight
  case notSent
}

// MARK: - Action

public enum DeliveriesAction: Equatable {
  case becameOffline
  case becameTrackable
  case cancelDeliveriesUpdate
  case enteredForeground
  case handleDeliveriesUpdate([DeliveryModel])
  case handleDeliveriesUpdateError(NonEmptyString)
  case saveCompletedDeliveries
  case selectDelivery(DeliveryModel)
  case updateDeliveries
}

// MARK: - Reducer

struct CancelDeliveries: Hashable { }
struct CancelDeliveriesTimer: Hashable { }

public let deliveriesReducer = Reducer<DeliveriesState, DeliveriesAction, SystemEnvironment<DeliveriesEnvironment>> { state, action, environment in
  switch action {
  case let .selectDelivery(delivery):
    return .none
  case let .handleDeliveriesUpdateError(error):
    state.networkStatus = .online(.notSent)
    return .none
  case let .handleDeliveriesUpdate(deliveries: deliveries):
    state.deliveries = deliveries
    state.networkStatus = .online(.notSent)
    return .concatenate(
      .cancel(id: CancelDeliveriesTimer()),
      Effect(value: .saveCompletedDeliveries)
    )
  case .becameTrackable,
       .enteredForeground,
       .updateDeliveries:
    if state.networkStatus == .online(.inFlight) {
      return .none
    } else {
      state.networkStatus = .online(.inFlight)
      return .merge(
        environment.getDeliveries(
          state.publishableKey,
          NonEmptyString(rawValue: try! HyperTrack(publishableKey: HyperTrack.PublishableKey(state.publishableKey.rawValue)!).deviceID)!
        )
          .receive(on: environment.mainQueue())
          .map { deliveriesResult in
              switch deliveriesResult {
              case let .left(deliveries):
                return .handleDeliveriesUpdate(deliveries)
              case let .right(error):
                return .handleDeliveriesUpdateError(error)
              }
          }
          .eraseToEffect()
          .cancellable(id: CancelDeliveries()),
        environment.deliveriesDismissTimer(environment.mainQueue())
          .receive(on: environment.mainQueue())
          .map { .cancelDeliveriesUpdate }
          .eraseToEffect()
          .cancellable(id: CancelDeliveriesTimer())
      )
    }
  case .cancelDeliveriesUpdate:
    state.networkStatus = .online(.notSent)
    return .cancel(id: CancelDeliveries())
  case .becameOffline:
    return .concatenate(
      .cancel(id: CancelDeliveries()),
      .cancel(id: CancelDeliveriesTimer())
    )
  case .saveCompletedDeliveries:
    return .none
  }
}
