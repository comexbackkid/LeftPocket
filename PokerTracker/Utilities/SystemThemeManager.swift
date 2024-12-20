//
//  SystemThemeManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/9/24.
//

import Foundation
import SwiftUI

class SystemThemeManager {
    static let shared = SystemThemeManager()
    init() {}
    
    func handleTheme(darkMode: Bool, system: Bool) {
        
        guard !system else {
//            UIApplication.shared.currentWindow?.overrideUserInterfaceStyle = .unspecified
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
            return
        }
        
//        UIApplication.shared.currentWindow?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
}
