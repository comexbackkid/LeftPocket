//
//  ToolTipCalculations+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/29/24.
//

import Foundation
import SwiftUI

extension SessionsListViewModel {
    
    // MARK: FUNCTIONS FOR STAKES PROGRESS INDICATOR
    
    func calculateTargetBankrollSize(from pokerSessions: [PokerSession]) -> Int? {
        guard let lastStake = pokerSessions.filter({ $0.isTournament == false || $0.isTournament == nil }).sorted(by: { $0.date > $1.date }).map({ $0.stakes }).first,
              let lastSlashIndex = lastStake.lastIndex(of: "/"),
              let bigBlind = Int(lastStake[lastSlashIndex...].trimmingCharacters(in: .punctuationCharacters)) else {
            
            return nil
        }

        // You want to have 60 buy-in's of your current stakes before advancing. 1 buy-in equals 100 big blinds. So, 100 x 60 = 6000 as our simple multiplier
        return bigBlind * 6000
    }
    
    // Called when Sessions is updated, will update the progress status for the stakes progress indicator
    func updateStakesProgress() {
        
        guard let targetBankroll = calculateTargetBankrollSize(from: sessions) else {
            return
        }
        
        self.stakesProgress = Float(tallyBankroll(bankroll: .all)) / Float(targetBankroll)
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
}
