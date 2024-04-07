//
//  AppReviewRequest.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/24/21.
//

import Foundation
import StoreKit
import UIKit
import SwiftUI


// Our func keeps track of how many runs are made, and then will appropriately display the review prompt using SKStoreReviewController
// The variables appBuild & appVersion keep track of the version so the user isn't prompted more than once per each update
enum AppReviewRequest {
    
    static var threshold = 2
    @AppStorage("runsSinceLastRequest") static var runsSinceLastRequest = 0
    @AppStorage("version") static var version = ""
    
    static func requestReviewIfNeeded() {
        runsSinceLastRequest += 1
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let thisVersion = "\(appVersion) build: \(appBuild)"
        
        if thisVersion != version {
            if runsSinceLastRequest >= threshold {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    version = thisVersion
                    runsSinceLastRequest = 0
                }
            }
        } else {
            runsSinceLastRequest = 0
        }
    }
}
