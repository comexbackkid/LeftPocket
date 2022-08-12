//
//  AppGroup.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/10/22.
//

import SwiftUI
import WidgetKit

struct AppGroup: Codable {
    
    let bankrollKey: String
    let lastSessionKey: String
    let chartKey: String
    let hourlyKey: String
    let totalSessionsKey: String
    let bankrollSuite: String
    
    static let keys = AppGroup(bankrollKey: "bankrollTotal",
                               lastSessionKey: "lastSessionAmount",
                               chartKey: "chartData",
                               hourlyKey: "hourlyKey",
                               totalSessionsKey: "sessionsKey",
                               bankrollSuite: "group.com.chrisnachtrieb.WidgetGroup")
}
