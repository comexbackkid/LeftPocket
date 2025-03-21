//
//  ToolTipCalculations+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/29/24.
//

import Foundation
import SwiftUI

enum UserRiskTolerance: String, CaseIterable {
    case conservative = "Conservative"
    case standard = "Standard"
    case aggressive = "Aggressive"
    
    var buyInMultiplier: Int {
        switch self {
        case .conservative: return 6000
        case .standard: return 4000
        case .aggressive: return 2000
        }
    }
}

extension SessionsListViewModel {
    
    // MARK: FUNCTIONS FOR STAKES PROGRESS INDICATOR
    
    func calculateTargetBankrollSize(from pokerSessions: [PokerSession_v2], riskTolerance: UserRiskTolerance) -> Int? {
        guard let lastStake = pokerSessions.filter({ !$0.isTournament }).sorted(by: { $0.date > $1.date }).map({ $0.stakes }).first,
              let lastSlashIndex = lastStake.lastIndex(of: "/"),
              let bigBlind = Int(lastStake[lastStake.index(after: lastSlashIndex)...])
                
        else {
            return nil
        }

        return bigBlind * riskTolerance.buyInMultiplier
    }
    
    var userRiskTolerance: UserRiskTolerance {
        UserRiskTolerance(rawValue: riskRaw) ?? .conservative
    }
    
    // Called when Sessions is updated, will update the progress status for the stakes progress indicator
    func updateBankrollProgressRing() {
        
        guard let targetBankroll = calculateTargetBankrollSize(from: sessions, riskTolerance: userRiskTolerance) else {
            return
        }
        
        let allTransactions = transactions.map({ $0.amount }).reduce(0, +)
        self.bankrollProgressRing = (Float(tallyBankroll(bankroll: .all)) + Float(allTransactions)) / Float(targetBankroll)
    }
    
    // MARK: BEST MONTH
    
    var bestMonth: String {
        mostProfitableMonth(in: sessions)
    }
    
    // MARK: FUNCTIONS FOR FINDING USER'S IDEAL SESSION LENGTH
    
    enum SessionLengthCategory: String {
        case lessThanThreeHours = "less than 3 hours"
        case threeToSixHours = "3-6 hours"
        case sixToNineHours = "6-9 hours"
        case moreThanNineHours = "over 9 hours"
    }
    
    func sessionCategory(from duration: Double) -> SessionLengthCategory {
        switch duration {
        case let x where x < 3: return .lessThanThreeHours
        case let x where x >= 3 && x <= 6: return .threeToSixHours
        case let x where x >= 6 && x <= 9: return .sixToNineHours
        default: return .moreThanNineHours
        }
    }

    func bestSessionLength() -> String {
        var categoryTotals = [SessionLengthCategory: (totalHourlyRate: Int, count: Int)]()

        for session in sessions {
            let duration = session.endTime.timeIntervalSince(session.startTime) / 3600 // Duration in hours
            let category = sessionCategory(from: duration)
            
            var current = categoryTotals[category, default: (totalHourlyRate: 0, count: 0)]
            current.totalHourlyRate += session.hourlyRate
            current.count += 1
              categoryTotals[category] = current
          }

          // Calculating average hourly rates for each category
          var maxAverage: Double = 0.0
          var mostProfitableCategory: SessionLengthCategory?

          for (category, data) in categoryTotals {
              let averageRate = data.count > 0 ? Double(data.totalHourlyRate) / Double(data.count) : 0.0
              if averageRate > maxAverage {
                  maxAverage = averageRate
                  mostProfitableCategory = category
              }
          }

          // Return the most profitable category
          return mostProfitableCategory?.rawValue ?? "... yikes. Keep at it!"
      }
    
    // MARK: USER'S MOST PROFITABLE MONTH
    
    func mostProfitableMonth(in sessions: [PokerSession_v2]) -> String {
        
        // Create a dictionary to store total profit for each month
        var monthlyProfits: [Int: Int] = [:]
        
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Iterate through sessions and accumulate profit for each month
        for session in sessions {
            
            let yearOfSession = Calendar.current.component(.year, from: session.date)
            
            // Check if the session is from the current year
            if yearOfSession == currentYear {
                let month = Calendar.current.component(.month, from: session.date)
                monthlyProfits[month, default: 0] += session.profit
            }
        }
        
        // Find the month with the highest profit
        if let mostProfitableMonth = monthlyProfits.max(by: { $0.value < $1.value }) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            let monthString = monthFormatter.monthSymbols[mostProfitableMonth.key - 1]
            
            return monthString
            
        } else {
            return "Undetermined"
        }
    }
    
    // MARK: CALCULATE USER'S WIN STREAK OR COLD STREAK
    
    func winStreak() -> Int {
        var streak = 0
        
        // Iterate through sessions in reverse order (from most recent to oldest)
        for session in sessions {
            if session.profit > 0 {
                // If on a win streak or neutral, increment the streak
                if streak >= 0 {
                    streak += 1
                } else {
                    break // Break if switching from a losing streak
                }
            } else if session.profit < 0 {
                // If on a losing streak or neutral, decrement the streak
                if streak <= 0 {
                    streak -= 1
                } else {
                    break // Break if switching from a win streak
                }
            } else {
                break // Streak ends on a neutral session (profit == 0)
            }
        }
        
        return streak
    }
}
