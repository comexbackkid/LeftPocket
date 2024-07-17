//
//  SceneDelegate.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/17/24.
//

import Foundation
import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    private let qaService = QAService.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let shortcutItem = connectionOptions.shortcutItem {
            qaService.action = QA(shortcutItem: shortcutItem)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        qaService.action = QA(shortcutItem: shortcutItem)
        completionHandler(true)
    }
}
