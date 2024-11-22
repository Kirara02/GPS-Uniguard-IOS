//
//  AppDelegate.swift
//  GPS Uniguard
//
//  Created by Uniguard ID on 22/11/24.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // URL default
        let defaultURL = "https://gps.uniguard.co.id"

        // Simpan URL default jika belum ada di UserDefaults
        if UserDefaults.standard.object(forKey: "url") == nil {
            UserDefaults.standard.set(defaultURL, forKey: "url")
        }

        // Langsung tampilkan MainViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        self.window?.makeKeyAndVisible()
        


        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    }
    
    func application(
            _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    

}

