//
//  Bundle+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/12/24.
//

import Foundation

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }
}
