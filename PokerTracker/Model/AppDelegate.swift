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

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Do I need this? Branch documentation doesn't mention it.
//        Branch.getInstance().checkPasteboardOnInstall()
        Branch.setUseTestBranchKey(true)
        
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            print(params as? [String: AnyObject] ?? {})
                // Access Deep Links data here (nav to page, display content, etc)
            
            
            if let code = params?["code"] as? String {
                print("Affiliate Code: \(code)")
            }
        }
        
//        let userID = UserDefaults.standard.string(forKey: "rcUserId")
//        Branch.getInstance().setIdentity(userID)
        
        return true 
    }
}
