//
//  AppDelegate.swift
//  Logistics
//
//  Created by rickb on 1/24/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import HyperTrack
import LogisticsKit
import SwiftUI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

		// Hypertrack uses silent push notifications to update tracking state
		HyperTrack.registerForRemoteNotifications()

		// Set the delegate to handle displaying notification alerts in-app and refresh data
		UNUserNotificationCenter.current().delegate = self

		return true
	}
}

/// Notification callbacks handled by Hypertrack
extension AppDelegate {

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		// HyperTrack and Logistics Manager need device token to send push notifications
		HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
		HypertrackLogisticsManager.shared.setToken(deviceToken)
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error)
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// send notification payload to HyperTrack and LogisticsManager
		HypertrackLogisticsManager.shared.didReceiveRemoteNotification(userInfo)
		HyperTrack.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
	}
}

/// Notification handling
extension AppDelegate: UNUserNotificationCenterDelegate {

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert])
	}

	/// Handle user tap on notification, for a delivery notification the app will refresh the delivery data and present the delivery detail screen
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		guard let deliveryId = response.notification.request.content.userInfo["delivery_id"] as? String else {
			completionHandler()
			return
		}
		let delivery = HypertrackLogisticsManager.shared.delivery(with: deliveryId)
		delivery.refresh().untilCompletion { _ in
			let contentView = NavigationView {
				DeliveryView(deliveryValue: delivery)
			}
			.environmentObject(defaultTheme)
			.environmentObject(HypertrackLogisticsManager.shared)

			let window = UIApplication.shared.windows.first { $0.isKeyWindow }!.rootViewController! // swiftlint:disable:this force_unwrapping
			window.present(UIHostingController(rootView: contentView), animated: true, completion: nil)
			completionHandler()
		}
	}
}
