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

enum AppReviewRequest {
    
    static var threshold = 3
    @AppStorage("runsSinceLastRequest") static var runsSinceLastRequest = 0
    @AppStorage("lastMajorMinorVersion") static var lastMajorMinorVersion = ""
    
    static func requestReviewIfNeeded() {
        runsSinceLastRequest += 1
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let majorMinorVersion = extractMajorMinorVersion(from: appVersion)
        
        // If the major or minor version has changed, we consider prompting a review
        if majorMinorVersion != lastMajorMinorVersion, runsSinceLastRequest >= threshold {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                lastMajorMinorVersion = majorMinorVersion
                runsSinceLastRequest = 0
            }
        }
    }
    
    // Extracts the major and minor parts of the version string (e.g., "4.8.1" -> "4.8").
    private static func extractMajorMinorVersion(from version: String) -> String {
        let components = version.split(separator: ".")
        guard components.count >= 2 else { return version }
        return components[0] + "." + components[1] // Only keep major and minor
    }
}
