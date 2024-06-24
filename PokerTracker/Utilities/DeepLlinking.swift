//
//  DeepLlinking.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/24/24.
//

import Foundation
import NotificationCenter

// Currently only handling one Deep Link for AppStore Connect's "In-App Events" feature
func handleDeepLinkURL(url: URL) {
    guard let host = url.host else { return }
    
    if host == "metrics" {
        NotificationCenter.default.post(name: .openMetricsView, object: nil)
    }
}

extension Notification.Name {
    static let openMetricsView = Notification.Name("openMetricsView")
}
