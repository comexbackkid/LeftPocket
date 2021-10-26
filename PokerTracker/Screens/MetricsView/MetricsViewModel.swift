//
//  MetricsViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/13/21.
//

import SwiftUI


//class MetricsViewModel: ObservableObject {
//
//    let sessions: [PokerSession]
//    
//    init(sessions: [PokerSession]) {
//        self.sessions = sessions
//    }
//
//    // Creates an array of our running, cumulative bankroll for use with SwiftUICharts
//    func chartArray() -> [Double] {
//        let profitsArray = sessions.map { Double($0.profit) }
//        var cumBankroll = [Double]()
//        var runningTotal = 0.0
//        
//        for value in profitsArray {
//            runningTotal += value
//            cumBankroll.append(runningTotal)
//        }
//        return cumBankroll
//    }
//    
//    // Function to calculate hourly earnings rate for MetricsView
//    func hourlyRate() -> Int {
//        guard sessionsCheck != nil else { return 0 }
//        let hoursArray = sessions.map { Int($0.gameDuration.hour ?? 0) }
//        let totalHours = hoursArray.reduce(0, +)
//        let totalBankroll = tallyBankroll()
//        return totalBankroll / totalHours
//    }
//    
//    // Function to calculate average session duration
//    func avgDuration() -> String {
//        guard sessionsCheck != nil else { return "0" }
//        let hoursArray: [Int] = sessions.map { $0.gameDuration.hour ?? 0 }
//        let minutesArray: [Int] = sessions.map { $0.gameDuration.minute ?? 0 }
//        let totalHours = hoursArray.reduce(0, +) / sessions.count
//        let totalMinutes = minutesArray.reduce(0, +) / sessions.count
//        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
//
//        return dateComponents.formattedDuration
//    }
//
//}

