//
//  AppGroup.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/10/22.
//

import SwiftUI
import WidgetKit

class AppGroup {
    
    let bankrollKey = "bankrollTotal"
    let lastSessionKey = "lastSessionAmount"
    let chartKey = "chartData"
    let hourlyKey = "hourlyKey"
    let totalSessionsKey = "sessionsKey"
    let bankrollSuite = "group.bankrollData"

    // Function that saves data we want transferred over to the Widget Target
    func writeToWidget(bankroll: Int, lastSessionAmount: Int, chartPoints: [Point], hourlyRate: Int, totalSessions: Int) {
        guard let defaults = UserDefaults(suiteName: bankrollSuite) else {
            print("Unable to write to User Defaults!")
            return
        }
        
        defaults.set(bankroll, forKey: bankrollKey)
        defaults.set(lastSessionAmount, forKey: lastSessionKey)
        defaults.set(hourlyRate, forKey: hourlyKey)
        defaults.set(totalSessions, forKey: totalSessionsKey)
        
        guard let chartData = try? JSONEncoder().encode(chartPoints) else {
            print("Error writing chart data")
            return
        }
        
        defaults.set(chartData, forKey: chartKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
