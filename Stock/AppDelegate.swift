//
//  AppDelegate.swift
//  Stock
//
//  Created by Kim Younghoo on 11/11/17.
//  Copyright © 2017 0hoo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //[C1-3]
    let tabBarController = UITabBarController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //[C1-4]
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: GroupsViewController()),
            UINavigationController(rootViewController: StocksViewController())
        ]

        window = UIWindow(frame: UIScreen.main.bounds)
        //[C1-5]
        window?.rootViewController = tabBarController
        //[C3-1]
        window?.tintColor = .themeBlue
        window?.makeKeyAndVisible()
        
        return true
    }
}
