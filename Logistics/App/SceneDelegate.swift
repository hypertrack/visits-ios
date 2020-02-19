//
//  SceneDelegate.swift
//  Logistics
//
//  Created by rickb on 1/24/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		window = (scene as? UIWindowScene)?.appWindow()
	}
}
