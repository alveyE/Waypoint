//
//  AppDelegate.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var shouldRefresh = true
    
    var timeEnded = NSDate()
    let minutesInactiveBeforeRefresh = 5.0
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        
    
        
      //  Database.database().isPersistenceEnabled = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        timeEnded = NSDate()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        shouldRefresh = timeEnded.timeIntervalSinceNow < minutesInactiveBeforeRefresh * -60
        if shouldRefresh {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        print("set refresh to \(shouldRefresh) since timeInterval was \(timeEnded.timeIntervalSinceNow)")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        
        if CLLocationManager.locationServicesEnabled() {
             switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                     let alert = UIAlertController(title: "Please enable loction services", message: "", preferredStyle: UIAlertController.Style.alert)
                     alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertAction.Style.default, handler: { action in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                     }))
                     UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
             case .authorizedAlways, .authorizedWhenInUse: break

            @unknown default:
                fatalError()
            }
            } else {
                let alert = UIAlertController(title: "Please enable loction services", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertAction.Style.default, handler: { action in
                   if let url = URL(string: UIApplication.openSettingsURLString) {
                       if UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url, options: [:], completionHandler: nil)
                       }
                   }
                }))
                UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            
        }
        
        if Auth.auth().currentUser?.isAnonymous ?? false{
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        
        let presentedController = UIApplication.topViewController()
        if (Auth.auth().currentUser == nil && !(presentedController is SignUpViewController || inSignUpProcess())) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "signinNavigation")
        }
        
    }

    func inSignUpProcess() -> Bool {
        var signingUp = false
        let vc = UIApplication.topViewController()
        if (vc is EnterEmailViewController || vc is CreatePasswordViewController || vc is CreateUsernameViewController || vc is BirthdaySelectorViewController || vc is TermsPrivacyAgreeViewController){
            signingUp = true
        }
        print("Signing Up be \(signingUp)")
        return signingUp
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
