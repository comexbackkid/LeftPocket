//
//  UIWindow+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/21/21.
//

import UIKit

public extension UIApplication {
    var currentScene: UIWindowScene? {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first
    }
}

public extension UIApplication {
    var currentWindow: UIWindow? {
        
        if #available(iOS 13.0, *) {
            if let window = self.currentScene?.frontWindow { return window }
            return nil
            
        } else {
            if let window = self.delegate?.window { return window }
            return self.windows.first
        }
    }
}

public extension UIWindowScene {
    var frontWindow: UIWindow? {
        if let window = self.windows.first(where: { $0.isKeyWindow }) { return window }
        return self.windows.first
    }

    var mainWindow: UIWindow? {
        if let window = self.windows.first(where: { $0.windowLevel == .normal }) { return window }
        return self.windows.first
    }
}
