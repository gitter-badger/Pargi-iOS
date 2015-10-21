//
//  AppDelegate.swift
//  Pargi
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Valmista mudel ette
        DataStore.initializeSharedInstance { (success, error) in
            if !success {
                // Midagi ebaõnnestus, crashi
                abort()
            } else {
                // Kõik läks hästi, viska ajutine UI minema
            }
        }
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        DataStore.sharedInstance.save()
    }
}
