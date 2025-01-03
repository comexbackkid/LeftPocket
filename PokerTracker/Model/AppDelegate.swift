//
//  AppDelegate.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/6/24.
//

import Foundation
import SwiftUI
import BranchSDK
import AdSupport
import RevenueCat
import ActivityKit
import UIKit
import InterfaceOrientation

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Handles Orientation Functionality
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            InterfaceOrientationCoordinator.shared.supportedOrientations
        }
    
    // MARK: QuickAction Functionality
    private let qaService = QAService.shared
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            if let shortcutItem = options.shortcutItem {
                qaService.action = QA(shortcutItem: shortcutItem)
            }
            let configuration = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
            configuration.delegateClass = SceneDelegate.self
            return configuration
        }
    
    // MARK: Branch Metrics Functionality
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Branch.setUseTestBranchKey(true)
        
//        Branch.getInstance().checkPasteboardOnInstall()
        Branch.getInstance().enableLogging()
        
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            print(params as? [String: AnyObject] ?? {})
                // Access Deep Links data here (nav to page, display content, etc)
            
            guard error == nil else {
                print("Initialization failed. Reason: " + (error?.localizedDescription ?? "No error found."))
                return
            }
            
            if let code = params?["code"] as? String {
                print("Affiliate Code: \(code)")
                
            }
            
            Branch.getInstance().logout { (changed, error) in
                if (error != nil || !changed) {
                    print("Logout failed: " + (error?.localizedDescription ?? "Unknown error"))
            } else {
                    print("Logout succeeded")
                }
            }
            
            let userID = UserDefaults.standard.string(forKey: "rcUserId")
            Branch.getInstance().setIdentity(userID)
            print("Branch User ID: " + (userID ?? "UNKNOWN"))
        }
        
        return true 
        
    }
}
