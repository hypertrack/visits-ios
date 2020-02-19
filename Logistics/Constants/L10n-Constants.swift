// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel")
  /// OK
  internal static let ok = L10n.tr("Localizable", "ok")

  internal enum DeliveriesView {
    /// Completed at %@
    internal static func completedAt(_ p1: String) -> String {
      return L10n.tr("Localizable", "DeliveriesView.completedAt", p1)
    }
    /// Today
    internal static let today = L10n.tr("Localizable", "DeliveriesView.today")
    /// Location tracking is active.
    internal static let trackingActive = L10n.tr("Localizable", "DeliveriesView.trackingActive")
    /// Location tracking is inactive.
    internal static let trackingInactive = L10n.tr("Localizable", "DeliveriesView.trackingInactive")
    /// Welcome, %@
    internal static func welcome(_ p1: String) -> String {
      return L10n.tr("Localizable", "DeliveriesView.welcome", p1)
    }
  }

  internal enum DeliveryStatus {
    /// Completed deliveries
    internal static let completed = L10n.tr("Localizable", "DeliveryStatus.completed")
    /// Pending deliveries
    internal static let pending = L10n.tr("Localizable", "DeliveryStatus.pending")
    /// Visited deliveries
    internal static let visited = L10n.tr("Localizable", "DeliveryStatus.visited")
  }

  internal enum DeliveryView {
    /// Completed at
    internal static let completedAt = L10n.tr("Localizable", "DeliveryView.completedAt")
    /// Customer Note
    internal static let customerNote = L10n.tr("Localizable", "DeliveryView.customerNote")
    /// Delivery Note
    internal static let deliveryNote = L10n.tr("Localizable", "DeliveryView.deliveryNote")
    /// Delivery Picture
    internal static let deliveryPicture = L10n.tr("Localizable", "DeliveryView.deliveryPicture")
    /// Items
    internal static let items = L10n.tr("Localizable", "DeliveryView.items")
    /// Last visit
    internal static let lastVisit = L10n.tr("Localizable", "DeliveryView.lastVisit")
    /// Location
    internal static let location = L10n.tr("Localizable", "DeliveryView.location")
    /// Mark completed
    internal static let markCompleted = L10n.tr("Localizable", "DeliveryView.markCompleted")
    /// Replace Picture
    internal static let replacePicture = L10n.tr("Localizable", "DeliveryView.replacePicture")
    /// Scan
    internal static let scan = L10n.tr("Localizable", "DeliveryView.scan")
    /// Take Picture
    internal static let takePicture = L10n.tr("Localizable", "DeliveryView.takePicture")
    /// Visited
    internal static let visited = L10n.tr("Localizable", "DeliveryView.visited")
    /// You visited %1$d out of %2$d deliveries so far.
    internal static func visitedDeliveries(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "DeliveryView.visitedDeliveries", p1, p2)
    }
  }

  internal enum LoginView {
    /// Check In
    internal static let checkin = L10n.tr("Localizable", "LoginView.checkin")
    /// Select Driver ID
    internal static let selectDriverId = L10n.tr("Localizable", "LoginView.selectDriverId")
    /// hLogistics
    internal static let title = L10n.tr("Localizable", "LoginView.title")
  }

  internal enum PermissionError {
    /// User denied Core Motion access
    internal static let userDeniedCoreMotion = L10n.tr("Localizable", "PermissionError.userDeniedCoreMotion")
    /// User denied location access
    internal static let userDeniedLocation = L10n.tr("Localizable", "PermissionError.userDeniedLocation")
    /// User denied notification permissions
    internal static let userDeniedNotifications = L10n.tr("Localizable", "PermissionError.userDeniedNotifications")
  }

  internal enum PermissionsManager {
    /// HyperTrack Logistics Sample needs push notification access to notify you of changes in delivery status.
    internal static let notificationPermission = L10n.tr("Localizable", "PermissionsManager.notificationPermission")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "PermissionsManager.settings")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
