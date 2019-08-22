//
//  AppDelegate.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 21/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = UINavigationController(rootViewController: HomeViewController())
        self.window = window
        return true
    }
}
