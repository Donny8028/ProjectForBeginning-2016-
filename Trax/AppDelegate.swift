//
//  AppDelegate.swift
//  Trax
//
//  Created by 賢瑭 何 on 2016/3/23.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit

struct GPXURL {
    static let NotificationName = "URL Ratio Station"
    static let Key = "URL key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.NotificationName, object: self, userInfo: [GPXURL.Key:url])
        center.postNotification(notification)
        return true
    }

}

