//
//  AppDelegate.swift
//  GiftCardApp
//
//  Created by George Quentin Ngounou on 20/02/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import UIKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = storyboard.instantiateViewController(withIdentifier: HomeNavigationController.UIConstant.storyboardID)
        //let rootVC = BrowseProductsViewController()
        //let navigationController = UINavigationController(rootViewController: rootVC)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    // This method is where you handle URL opens if you are using a native scheme URLs (eg "yourexampleapp://")
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let stripeHandled = Stripe.handleURLCallback(with: url)

        if (stripeHandled) {
            return true
        } else {
            // This was not a stripe url, do whatever url handling your app
            // normally does, if any.
        }

        return false
    }

    // This method is where you handle URL opens if you are using univeral link URLs (eg "https://example.com/stripe_ios_callback")
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = Stripe.handleURLCallback(with: url)

                if (stripeHandled) {
                    return true
                } else {
                    // This was not a stripe url, do whatever url handling your app
                    // normally does, if any.
                }
            }
            
        }
        return false
    }
    

}

