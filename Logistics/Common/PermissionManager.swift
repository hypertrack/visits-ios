//
//  PermissionManager.swift
//  Logistics
//
//  Created by rickb on 2/5/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import CoreLocation
import CoreMotion
import Foundation
import UIKit
import UserNotifications

class PermissionsManager {

	static let shared = PermissionsManager()

	private lazy var locationManager = PermissionsLocationManager()
	private lazy var coreMotionManager = CMMotionActivityManager()

	enum Permission {
		case notification(UNAuthorizationOptions)
		case coreMotion
		case location(alwaysOn: Bool)

		var message: String {
			switch self {
			case .notification:
				return L10n.PermissionsManager.notificationPermission
			case .coreMotion:
				return Bundle.main.object(forInfoDictionaryKey: "NSMotionUsageDescription") as! String // swiftlint:disable:this force_cast
			case .location:
				return Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") as! String // swiftlint:disable:this force_cast
			}
		}

		var error: Error {
			switch self {
			case .notification:
				return PermissionError.userDeniedNotifications
			case .coreMotion:
				return PermissionError.userDeniedCoreMotion
			case .location:
				return PermissionError.userDeniedLocation
			}
		}

		var settingsURL: URL {
			URL(string: UIApplication.openSettingsURLString)! // swiftlint:disable:this force_unwrapping
		}
	}

	func requestAccess(_ permissions: [Permission], completion: @escaping (Error?) -> Void) {
		guard let permission = permissions.first else {
			DispatchQueue.main.async { completion(nil) }
			return
		}
		requestAccess(permission) { error in
			if let error = error {
				DispatchQueue.main.async { completion(error) }
			} else {
				self.requestAccess(Array(permissions.dropFirst()), completion: completion)
			}
		}
	}

	func requestAccess(_ permission: Permission, completion: @escaping (Error?) -> Void) {
		switch permission {
		case let .notification(options: options):
			requestNotificationAccess(permission, options: options, completion: completion)
		case .coreMotion:
			requestCoreMotionAccess(permission, completion: completion)
		case let .location(alwaysOn: alwaysOn):
			requestLocationAccess(permission, alwaysOn: alwaysOn, completion: completion)
		}
	}

	func requestNotificationAccess(_ permission: Permission, options: UNAuthorizationOptions, completion: @escaping (Error?) -> Void) {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			DispatchQueue.main.async {
				switch settings.authorizationStatus {
				case .notDetermined:
					UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
						DispatchQueue.main.async { completion(error) }
					}
				case .denied:
					permission.showAlert(completion: completion)
				default:
					DispatchQueue.main.async { completion(nil) }
				}
			}
		}
	}

	func requestCoreMotionAccess(_ permission: Permission, completion: @escaping (Error?) -> Void) {
		switch CMMotionActivityManager.authorizationStatus() {
		case .notDetermined:
			coreMotionManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, error in
				self.coreMotionManager.stopActivityUpdates()
				DispatchQueue.main.async { completion(error) }
			}
		case .restricted, .denied:
			permission.showAlert(completion: completion)
		default:
			DispatchQueue.main.async { completion(nil) }
		}
	}

	func requestLocationAccess(_ permission: Permission, alwaysOn: Bool, completion: @escaping (Error?) -> Void) {
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			locationManager.request(alwaysOn, completion: completion)
		case .restricted, .denied:
			permission.showAlert(completion: completion)
		default:
			DispatchQueue.main.async { completion(nil) }
		}
	}
}

private extension PermissionsManager.Permission {

	func showAlert(completion: @escaping (Error?) -> Void) {
		UIAlertController.alert(title: message)
		.action(title: L10n.PermissionsManager.settings) { _ in
			UIApplication.shared.open(self.settingsURL, options: [:], completionHandler: nil)
			DispatchQueue.main.async { completion(self.error) }
		}
		.cancel { _ in
			DispatchQueue.main.async { completion(self.error) }
		}
		.show(in: UIApplication.shared.windows.first { $0.isKeyWindow }!.rootViewController!) // swiftlint:disable:this force_unwrapping
	}
}

private class PermissionsLocationManager: CLLocationManager, CLLocationManagerDelegate {

	private var completion: ((Error?) -> Void)?

	func request(_ alwaysOn: Bool, completion: @escaping (Error?) -> Void) {
		self.completion = completion
		delegate = self
		if alwaysOn {
			requestAlwaysAuthorization()
		} else {
			requestWhenInUseAuthorization()
		}
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .notDetermined:
			break
		case .restricted, .denied:
			if let completion = self.completion {
				DispatchQueue.main.async {
					completion(PermissionError.userDeniedLocation)
				}
			}
			completion = nil
		default:
			if let completion = self.completion {
				DispatchQueue.main.async {
					completion(nil)
				}
			}
			completion = nil
		}
	}
}

enum PermissionError: LocalizedError {

	case userDeniedLocation
	case userDeniedCoreMotion
	case userDeniedNotifications

	var errorDescription: String? {
		switch self {
		case .userDeniedLocation:
			return L10n.PermissionError.userDeniedLocation
		case .userDeniedCoreMotion:
			return L10n.PermissionError.userDeniedCoreMotion
		case .userDeniedNotifications:
			return L10n.PermissionError.userDeniedNotifications
		}
	}
}
