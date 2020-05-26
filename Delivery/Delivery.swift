import Foundation
import UIKit
import Prelude
import ComposableArchitecture
import CoreLocation

// MARK: - Environment

public typealias DeliveryEnvironment = (
  sendDeliveryCompletion: (_ publishableKey: NonEmptyString, _ geofenceID: NonEmptyString) -> Effect<Never, Never>,
  sendDeliveryNote: (_ publishableKey: NonEmptyString, _ note: NonEmptyString, _ geofenceID: NonEmptyString) -> Effect<Never, Never>,
  openAppleMap: (_ address: NonEmptyString, _ coordinate: CLLocationCoordinate2D) -> Effect<Never, Never>
)

public let live = DeliveryEnvironment(
  sendDeliveryCompletion: sendDeliveryCompletion,
  sendDeliveryNote: sendDeliveryNote,
  openAppleMap: openAppleMap
)

// MARK: - State

public enum AlertContent: String {
  case none
  case copy = "Copied!"
  case completedDelivery = "Delivery Completed!"
  case metadataSent = "Note sent!"
}

public struct DeliveryState: Equatable {
  public let publishableKey: NonEmptyString
  public let delivery: SingleDelivery
  public var deliveryNote: String
  public var isNoteFieldFocused: Bool
  public var isDeliveryCompleted: Bool
  public var alertContent: AlertContent
  
  public init(publishableKey: NonEmptyString, delivery: SingleDelivery, deliveryNote: String, isNoteFieldFocused: Bool, isDeliveryCompleted: Bool, alertContent: AlertContent) {
    self.publishableKey = publishableKey
    self.delivery = delivery
    self.deliveryNote = deliveryNote
    self.isNoteFieldFocused = isNoteFieldFocused
    self.isDeliveryCompleted = isDeliveryCompleted
    self.alertContent = alertContent
  }
  
  public static func initialState(publishableKey: NonEmptyString, delivery: SingleDelivery, isDeliveryCompleted: Bool, alertContent: AlertContent) -> DeliveryState {
    DeliveryState(publishableKey: publishableKey, delivery: delivery, deliveryNote: "", isNoteFieldFocused: false, isDeliveryCompleted: isDeliveryCompleted, alertContent: alertContent)
  }
}

extension SingleDelivery {
  public func coordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
  }
}

// MARK: - Action

public enum DeliveryAction: Equatable {
  case alertPresentingFinished
  case changeDeliveryNote(String)
  case completeDelivery
  case copyDeliverySection(String)
  case deselectDelivery
  case focusDeliveryNote
  case openAppleMaps
  case saveCompletedDeliveries
  case sendDeliveryNote
  case unfocusDeliveryNote
}

public let deliveryReducer = Reducer<DeliveryState, DeliveryAction, SystemEnvironment<DeliveryEnvironment>> { state, action, environment in
  switch action {
  case .deselectDelivery:
    return .none
  case .openAppleMaps:
    let address: NonEmptyString
    if let nonEmptyAddress = NonEmptyString(rawValue: state.delivery.shortAddress) {
      address = nonEmptyAddress
    } else {
      address = NonEmptyString("Your delivery")
    }
    return environment
      .openAppleMap(address, state.delivery.coordinate())
      .fireAndForget()
  case let .copyDeliverySection(copyTest):
    if let text = NonEmptyString(rawValue: copyTest) {
      UIPasteboard.general.string = text.rawValue
      state.alertContent = .copy
    }
    return .none
  case .completeDelivery:
    state.isDeliveryCompleted = true
    state.alertContent = .completedDelivery
    return .merge(
      environment
        .sendDeliveryCompletion(state.publishableKey, state.delivery.id)
        .fireAndForget(),
      Effect(value: .saveCompletedDeliveries)
    )
  case .focusDeliveryNote:
    state.isNoteFieldFocused = true
    return .none
  case let .changeDeliveryNote(text):
    state.deliveryNote = text
    return .none
  case .sendDeliveryNote:
    state.isNoteFieldFocused = false
    if let note = NonEmptyString(rawValue: state.deliveryNote) {
      state.alertContent = .metadataSent
      state.deliveryNote = ""
      return environment
        .sendDeliveryNote(state.publishableKey, note, state.delivery.id)
        .fireAndForget()
    }
    return .none
  case .unfocusDeliveryNote:
    state.isNoteFieldFocused = false
    return .none
  case .saveCompletedDeliveries:
    return .none
  case .alertPresentingFinished:
    state.alertContent = .none
    return .none
  }
}
