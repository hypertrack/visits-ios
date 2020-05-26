import ComposableArchitecture
import Prelude
import Delivery

// MARK: - Deeplink

import Deeplink

extension AppState {
  var deeplinkable: Void? {
    get {
      if case .new = userStatus {
        return ()
      } else {
        return nil
      }
    }
    set {}
  }
}

extension AppAction {
  static let deeplinkCasePath: CasePath<AppAction, DeeplinkAction> = CasePath(
    embed: { deeplinkAction in
      switch deeplinkAction {
      case .appAppeared:
        return .appAppeared
      case let .receivedDeeplink(deeplink):
        return .receivedDeeplink(deeplink)
      case let .signedIn(publishableKey):
        return .signIn(.done(.signedIn(publishableKey: publishableKey)))
      }
    },
    extract: { appAction in
      switch appAction {
      case .appAppeared:
        return .appAppeared
      case let receivedDeeplink(deeplink):
        return .receivedDeeplink(deeplink)
      case let .signIn(.done(.signedIn(publishableKey: publishableKey))):
        return  .signedIn(publishableKey: publishableKey)
      default:
        return nil
      }
  }
  )
}

// MARK: - Deliveries
import Deliveries

extension AppState {
  var deliveriesState: DeliveriesState? {
    get {
      if case let .registered(registeredStruct) = userStatus {
        
        if case .some = registeredStruct.user.selectedDelivery {
          return nil
        }
        
        let network: Deliveries.NetworkStatus
        switch networkStatus {
        case let .online(requestStatus):
          network = .online(requestStatus.deliveriesRequestStatus ? .inFlight : .notSent)
        case .offline:
          network = .offline
        }
        
        let deliveries = DeliveriesState(
          publishableKey: registeredStruct.user.publishableKey,
          deliveries: registeredStruct.user.deliveries,
          networkStatus: network,
          isTracking: registeredStruct.user.trackingStatus == .tracking
        )
        return deliveries
      } else {
        return nil
      }
    }
    set {
      if let value = newValue {
        switch value.networkStatus {
        case let .online(rStatus):
          switch rStatus {
          case .inFlight:
            networkStatus = .online(RequestStatus(deliveriesRequestStatus: true))
          case .notSent:
            networkStatus = .online(RequestStatus(deliveriesRequestStatus: false))
          }
        case .offline:
          networkStatus = .offline
        }
        if case var .registered(reg) = userStatus {
          reg.user.deliveries = value.deliveries
          userStatus = .registered(reg)
        }
      }
    }
  }
}

extension AppAction {
  static let deliveriesCasePath: CasePath<AppAction, DeliveriesAction> = CasePath(
    embed: { deliveriesAction in
      switch deliveriesAction {
      case .becameTrackable:
        return .becameTrackable
      case let .selectDelivery(delivery):
        return .selectDelivery(delivery)
      case let .handleDeliveriesUpdate(deliveries):
        return .handleDeliveriesUpdate(deliveries)
      case let .handleDeliveriesUpdateError(error):
        return .handleDeliveriesUpdateError(error)
      case .updateDeliveries:
        return .updateDeliveries
      case .enteredForeground:
        return .enteredForeground
      case .cancelDeliveriesUpdate:
        return .cancelDeliveriesUpdate
      case .becameOffline:
        return .reachability(.reachabilityChanged(false))
      case .saveCompletedDeliveries:
        return .saveCompletedDeliveries
      }
    },
    extract: { appAction in
      switch appAction {
      case .becameTrackable:
      return .becameTrackable
      case let .selectDelivery(delivery):
        return .selectDelivery(delivery)
      case let .handleDeliveriesUpdate(deliveries):
        return .handleDeliveriesUpdate(deliveries)
      case let .handleDeliveriesUpdateError(error):
        return .handleDeliveriesUpdateError(error)
      case .updateDeliveries:
        return .updateDeliveries
      case .enteredForeground:
        return .enteredForeground
      case .cancelDeliveriesUpdate:
        return .cancelDeliveriesUpdate
      case .reachability(.reachabilityChanged(false)):
        return .becameOffline
      case .saveCompletedDeliveries:
      return .saveCompletedDeliveries
      default:
        return nil
      }
    }
  )
}

// MARK: - Delivery

extension AppState {
  var deliveryState: DeliveryState? {
    get {
      if case let .registered(registeredStruct) = userStatus {
        
        if case .none = registeredStruct.user.selectedDelivery {
          return nil
        }

        let selectedDelivery = SingleDelivery(
          id: registeredStruct.user.selectedDelivery!.id,
          lat: registeredStruct.user.selectedDelivery!.lat,
          lng: registeredStruct.user.selectedDelivery!.lng,
          shortAddress: registeredStruct.user.selectedDelivery!.shortAddress,
          fullAddress: registeredStruct.user.selectedDelivery!.fullAddress,
          metadata: registeredStruct.user.selectedDelivery!.metadata.map {
            SingleDelivery.Metadata(key: $0.key, value: $0.value)
          })
        
        let delivery = DeliveryState(
          publishableKey: registeredStruct.user.publishableKey,
          delivery: selectedDelivery,
          deliveryNote: registeredStruct.user.deliveryNote,
          isNoteFieldFocused: registeredStruct.user.isNoteFieldFocused,
          isDeliveryCompleted: registeredStruct.user.completedDeliveries.contains { $0 == selectedDelivery.id },
          alertContent: registeredStruct.user.alertContent
        )

        return delivery
      } else {
        return nil
      }
    }
    set {
      if let value = newValue {
        if case var .registered(reg) = userStatus {
          reg.user.deliveryNote = value.deliveryNote
          reg.user.isNoteFieldFocused = value.isNoteFieldFocused
          reg.user.alertContent = value.alertContent
          
          if value.isDeliveryCompleted, !reg.user.completedDeliveries.contains(where: { $0 == value.delivery.id }) {
            reg.user.completedDeliveries += [value.delivery.id]
          }
          
          userStatus = .registered(reg)
        }
      }
    }
  }
}

extension AppAction {
  static let deliveryCasePath: CasePath<AppAction, DeliveryAction> = CasePath(
    embed: { deliveriesAction in
      switch deliveriesAction {
      case let .copyDeliverySection(copyText):
        return .copyDeliverySection(copyText)
      case .deselectDelivery:
        return .deselectDelivery
      case .unfocusDeliveryNote:
        return .unfocusDeliveryNote
      case .completeDelivery:
        return .completeDelivery
      case .sendDeliveryNote:
        return .sendDeliveryNote
      case .focusDeliveryNote:
        return .focusDeliveryNote
      case let .changeDeliveryNote(noteText):
        return .changeDeliveryNote(noteText)
      case .openAppleMaps:
        return .openAppleMaps
      case .saveCompletedDeliveries:
        return .saveCompletedDeliveries
      case .alertPresentingFinished:
        return .alertPresentingFinished
      }
    },
    extract: { appAction in
      switch appAction {
      case let .copyDeliverySection(copyText):
        return .copyDeliverySection(copyText)
      case .deselectDelivery:
        return .deselectDelivery
      case .unfocusDeliveryNote:
        return .unfocusDeliveryNote
      case .completeDelivery:
        return .completeDelivery
      case .sendDeliveryNote:
        return .sendDeliveryNote
      case .focusDeliveryNote:
        return .focusDeliveryNote
      case let .changeDeliveryNote(noteText):
        return .changeDeliveryNote(noteText)
      case .openAppleMaps:
        return .openAppleMaps
      case .saveCompletedDeliveries:
        return .saveCompletedDeliveries
      case .alertPresentingFinished:
        return .alertPresentingFinished
      default:
        return nil
      }
    }
  )
}

// MARK: - Location

import Location

public enum LocationActionAdapter: Equatable {
  case grant(GrantOption)
  case permissionsChanged(LocationPermissions)
  case startMonitoring
  case stopMonitoring
}

extension AppAction {
  static let locationCasePath: CasePath<AppAction, LocationAction> = CasePath(
    embed: { locationAction in
      switch locationAction {
      case .appAppeared:
        return .appAppeared
      case let .grant(option):
        return .location(.grant(option))
      case let .permissionsChanged(update):
        return .location(.permissionsChanged(update))
      case .startMonitoring:
        return .location(.startMonitoring)
      case .stopMonitoring:
        return .location(.stopMonitoring)
      }
    },
    extract: { appAction in
      switch appAction {
      case let .location(.grant(option)):
        return .grant(option)
      case let .location(.permissionsChanged(update)):
        return .permissionsChanged(update)
      case .location(.startMonitoring):
        return .startMonitoring
      case .location(.stopMonitoring):
        return .stopMonitoring
      case .appAppeared:
        return .appAppeared
      default:
        return nil
      }
    }
  )
}


// MARK: - Motion

import Motion

public enum MotionActionAdapter: Equatable {
  case changed(MotionAction.Update)
  case check
}

extension AppAction {
  static let motionCasePath: CasePath<AppAction, MotionAction> = CasePath(
    embed: { motionAction in
      switch motionAction {
      case .appAppeared:
        return .appAppeared
      case let .changed(update):
        return .motion(.changed(update))
      case .check:
        return .motion(.check)
      case .enteredForeground:
        return .enteredForeground
      }
    },
    extract: { appAction in
      switch appAction {
      case .appAppeared:
        return .appAppeared
      case .enteredForeground:
        return .enteredForeground
      case let .motion(.changed(update)):
        return .changed(update)
      case .motion(.check):
        return .check
      default:
        return nil
      }
    }
  )
}

// MARK: - Notification

import Notification

extension AppAction {
  static let notificationCasePath: CasePath<AppAction, NotificationAction> = CasePath(
    embed: { notificationAction in
      switch notificationAction {
      case .appAppeared:
        return .appAppeared
      case .enteredForeground:
        return .enteredForeground
      }
    },
    extract: { appAction in
      switch appAction {
      case .appAppeared:
        return .appAppeared
      case .enteredForeground:
        return .enteredForeground
      default:
        return nil
      }
    }
  )
}

// MARK: - Reachability

import Reachability

extension AppState {
  var reachability: ReachabilityState {
    get {
      ReachabilityState(isOnline: networkStatus == .offline, monitoring: monitoringReachability)
    }
    set {
      if networkStatus == .offline, newValue.isOnline {
        networkStatus = .online(RequestStatus(deliveriesRequestStatus: false))
      } else if !newValue.isOnline {
        networkStatus = .offline
      }
      monitoringReachability = newValue.monitoring
    }
  }
}

enum ReachabilityActionAdapter: Equatable {
  case reachabilityChanged(Bool)
  case stopMonitoring
}

extension AppAction {
  static let reachabilityCasePath: CasePath<AppAction, ReachabilityAction> = CasePath(
    embed: { reachabilityAction in
      switch reachabilityAction {
      case let .reachabilityChanged(change):
        return .reachability(.reachabilityChanged(change))
      case .startMonitoring:
        return .appAppeared
      case .stopMonitoring:
        return .reachability(.stopMonitoring)
      }
    },
    extract: { appAction in
      switch appAction {
      case .appAppeared:
        return .startMonitoring
      case let .reachability(.reachabilityChanged(change)):
        return .reachabilityChanged(change)
      case .reachability(.stopMonitoring):
        return .stopMonitoring
      default:
        return nil
      }
    }
  )
}

// MARK: - Restoration

import Restoration

extension AppState {
  var restoration: RestorationState {
    get {
      if case let .registered(registered) = userStatus {
        return RestorationState(completedDeliveries: registered.user.completedDeliveries)
      } else {
        return RestorationState(completedDeliveries: [])
      }
    }
    set {
      if case let .registered(registered) = userStatus {
        userStatus = .registered(
          registered |> \.user.completedDeliveries .~ newValue.completedDeliveries
        )
      }
    }
  }
}

extension AppAction {
  static let restorationCasePath: CasePath<AppAction, RestorationAction> = CasePath(
    embed: { restorationAction in
      switch restorationAction {
      case let .obtainedPublishableKey(publishableKey):
        return .signIn(.done(.signedIn(publishableKey: publishableKey)))
      case let .updatedDriverID(driverID):
        return .driverID(.register(driverID: driverID))
      case .saveCompletedDeliveries:
        return .saveCompletedDeliveries
      }
    },
    extract: { appAction in
      switch appAction {
      case let .driverID(.register(driverID)):
        return .updatedDriverID(driverID)
      case let .signIn(.done(.signedIn(publishableKey: publishableKey))):
        return .obtainedPublishableKey(publishableKey)
      case .saveCompletedDeliveries:
        return .saveCompletedDeliveries
      default:
      return nil
      }
    }
  )
}

// MARK: - Tracking
import Tracking

extension AppState {
  var tracking: TrackingState? {
    get {
      if case let .registered(registered) = userStatus {
        return TrackingState(
          driverID: registered.user.driverID,
          publishableKey: registered.user.publishableKey,
          trackingStatus: registered.user.trackingStatus
        )
      } else {
        return nil
      }
    }
    set {
      if case let .registered(registered) = userStatus,
        let tracking = newValue {
        self.userStatus = .registered(
          .init(
            user: .init(
              deliveries: registered.user.deliveries,
              driverID: tracking.driverID,
              publishableKey: tracking.publishableKey,
              selectedDelivery: registered.user.selectedDelivery,
              trackingStatus: tracking.trackingStatus,
              deliveryNote: registered.user.deliveryNote,
              isNoteFieldFocused: registered.user.isNoteFieldFocused,
              completedDeliveries: registered.user.completedDeliveries,
              alertContent: registered.user.alertContent
            )
          )
        )
      }
    }
  }
}

extension AppState {
  var trackable: Bool {
    if case .registered = userStatus,
      services.location.permissions == .granted,
      services.motion == .runtime(.authorized) {
      return true
    } else {
      return false
    }
  }
}

extension AppAction {
  static let trackingCasePath: CasePath<AppAction, TrackingAction> = CasePath(
    embed: { trackingAction in
      switch trackingAction {
      case .becameTrackable:
        return .becameTrackable
      case .enteredForeground:
        return .enteredForeground
      case .trackingStarted:
        return .trackingStarted
      case .trackingStopped:
        return .trackingStopped
      case .trialEnded:
        return .trialEnded
      }
    },
    extract: { appAction in
      switch appAction {
      case .becameTrackable:
        return .becameTrackable
      case .enteredForeground:
        return .enteredForeground
      case .trackingStarted:
        return .trackingStarted
      case .trackingStopped:
        return .trackingStopped
      case .trialEnded:
        return .trialEnded
      default:
      return nil
      }
    }
  )
}
