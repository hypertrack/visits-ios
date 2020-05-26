import Prelude

import ViewBlocker
import Location
import Deliveries

// MARK: - Blocker

extension AppState {
  var blocker: BlockReason? {
    if case .registered = userStatus {
      switch (services.location.permissions, services.motion) {
      case (.denied, _):
        return .locationPermissionsDenied
      case (.disabled, _):
        return .locationServiceDisabled
      case (.notRequested, _):
        return .locationPermissionsNotDetermined
      case (.restricted, _):
        return .locationPermissionsRestricted
      case (_, .final(.denied)):
        return .motionPermissionsDenied
      case (_, .final(.restart)):
        return .motionPermissionsNeedRestart
      case (_, .runtime(.restricted)), (_, .starting(.restricted)):
        return .motionServiceDisabled
      case (_, .runtime(.unknown)):
        return .motionPermissionsUnknown
      case (_, .starting(.notDetermined)):
        return .motionPermissionsNotDetermined
      default:
        if case let .registered(state) = userStatus,
           state.user.trackingStatus == .notTracking(freeLimitReached: true) {
          return .hyperTrackAccountTrialEnded
        } else {
          return nil
        }
      }
    }
    return nil
  }
}


extension AppAction {
  init(block: BlockAction) {
    switch block {
    case .openAppSettings:
      self = .location(.grant(.goToSettings))
    case .requestLocationPermissions:
      self = .location(.grant(.requestPermissions))
    case .requestMotionPermissions:
      self = .motion(.check)
    }
  }
}

// MARK: - Delivery

import Delivery

extension AppState {
  var deliveryView: DeliveryView.State? {
    if case let .registered(registered) = userStatus,
      let delivery = registered.user.selectedDelivery {
      
      let isAlertPresent: Bool
      let alertBody: NonEmptyString
      
      switch registered.user.alertContent {
      case .none: isAlertPresent = false
      case .metadataSent: isAlertPresent = true
      case .completedDelivery: isAlertPresent = true
      case .copy: isAlertPresent = true
      }
      
      alertBody = NonEmptyString(stringLiteral: registered.user.alertContent.rawValue)
      
      return DeliveryView.State(
        delivery: SingleDelivery(
          id: delivery.id,
          lat: delivery.lat,
          lng: delivery.lng,
          shortAddress: delivery.shortAddress,
          fullAddress: delivery.fullAddress,
          metadata: delivery.metadata.map { SingleDelivery.Metadata(key: $0.key, value: $0.value) }
        ),
        deliveryNote: registered.user.deliveryNote,
        isCompleted: registered.user.completedDeliveries.contains { $0 == delivery.id },
        isDeliveryCompleted: registered.user.completedDeliveries.contains { $0 == delivery.id },
        isNoteFieldFocused: registered.user.isNoteFieldFocused,
        isVisited: false, // TODO: update
        viewTitle: delivery.shortAddress.isEmpty ? NonEmptyString(stringLiteral: "Delivery") : NonEmptyString(stringLiteral: delivery.shortAddress),
        isAlertPresent: isAlertPresent,
        alertBody: alertBody
      )
    }
    return nil
  }
}

// MARK: - Deliveries

import Deliveries

extension AppState {
  var deliveriesView: DeliveriesView.State? {
    if case let .registered(registered) = userStatus,
    registered.user.selectedDelivery == nil {
      let completed = registered.user.deliveries.filter { registered.user.completedDeliveries.contains($0.id) }
      let pending = registered.user.deliveries.filter { !registered.user.completedDeliveries.contains($0.id) }
      let isNetworkAvailable: Bool
      let refreshing: Bool
      let refreshButtonDisabled: Bool
      switch networkStatus {
      case let .online(status):
        if status.deliveriesRequestStatus {
          refreshing = true
          refreshButtonDisabled = true
          isNetworkAvailable = true
        } else {
          refreshing = false
          refreshButtonDisabled = false
          isNetworkAvailable = true
        }
      case .offline:
        refreshing = false
        refreshButtonDisabled = true
        isNetworkAvailable = false
      }
      return DeliveriesView.State(
        completed: completed,
        isNetworkAvailable: isNetworkAvailable,
        isTracking: registered.user.trackingStatus == .tracking,
        pending: pending,
        refreshButtonDisabled: refreshButtonDisabled,
        refreshing: refreshing
      )
    }
    return nil
  }
}
