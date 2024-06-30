//
//  MetricsCalculations+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/28/24.
//

import Foundation
import SwiftUI

extension SessionsListViewModel {
    
    func countSessions(range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        switch bankroll {
        case .all:
            switch range {
            case .all:
                return sessions.count
            case .oneMonth:
                return filterSessionsLastMonth().count
            case .sixMonth:
                return filterSessionsLastSixMonths().count
            case .oneYear:
                return filterSessionsLastTwelveMonths().count
            case .ytd:
                return filterSessionsYTD().count
            }
        case .cash:
            switch range {
            case .all:
                return allCashSessions().count
            case .oneMonth:
                return filterSessionsLastMonth().filter { $0.isTournament != true }.count
            case .sixMonth:
                return filterSessionsLastSixMonths().filter { $0.isTournament != true }.count
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }.count
            case .ytd:
                return filterSessionsYTD().filter { $0.isTournament != true }.count
            }
        case .tournaments:
            switch range {
            case .all:
                return allTournamentSessions().count
            case .oneMonth:
                return filterSessionsLastMonth().filter { $0.isTournament == true }.count
            case .sixMonth:
                return filterSessionsLastSixMonths().filter { $0.isTournament == true }.count
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }.count
            case .ytd:
                return filterSessionsYTD().filter { $0.isTournament == true }.count
            }
        }
    }
    
    func tallyBankroll(range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        
        switch bankroll {
        case .all:
            switch range {
            case .all:
                return sessions.map { Int($0.profit) }.reduce(0, +)
            case .oneMonth:
                return filterSessionsLastMonth().map { Int($0.profit) }.reduce(0, +)
            case .sixMonth:
                return filterSessionsLastSixMonths().map { Int($0.profit) }.reduce(0, +)
            case .oneYear:
                return filterSessionsLastTwelveMonths().map { Int($0.profit) }.reduce(0, +)
            case .ytd:
                return filterSessionsYTD().map { Int($0.profit) }.reduce(0, +)
            }
            
        case .cash:
            switch range {
            case .all:
                return allCashSessions().map { Int($0.profit) }.reduce(0, +)
            case .oneMonth:
                return filterSessionsLastMonth().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
            case .sixMonth:
                return filterSessionsLastSixMonths().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
            case .ytd:
                return filterSessionsYTD().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
            }
            
        case .tournaments:
            switch range {
            case .all:
                return allTournamentSessions().map { Int($0.profit) }.reduce(0, +)
            case .oneMonth:
                return filterSessionsLastMonth().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
            case .sixMonth:
                return filterSessionsLastSixMonths().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
            case .ytd:
                return filterSessionsYTD().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
            }
        }
    }
    
    func hourlyRate(range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        
        var sessionsArray: [PokerSession] {
            switch bankroll {
            case .all:
                switch range {
                case .all:
                    return sessions
                case .oneMonth:
                    return filterSessionsLastMonth()
                case .sixMonth:
                    return filterSessionsLastSixMonths()
                case .oneYear:
                    return filterSessionsLastTwelveMonths()
                case .ytd:
                    return filterSessionsYTD()
                }
                
            case .cash:
                switch range {
                case .all:
                    return allCashSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter{ $0.isTournament != true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter{ $0.isTournament != true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter{ $0.isTournament != true }
                case .ytd:
                    return filterSessionsYTD().filter{ $0.isTournament != true }
                }
                
            case .tournaments:
                switch range {
                case .all:
                    return allTournamentSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter{ $0.isTournament == true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
                case .ytd:
                    return filterSessionsYTD().filter{ $0.isTournament == true }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        
        let totalHours = Float(sessionsArray.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+))
        let totalMinutes = Float(sessionsArray.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
        
        // Add up all the hours & minutes together to simply get a sum of hours
        let totalTime = totalHours + (totalMinutes / 60)
        let totalEarnings = Float(tallyBankroll(range: range, bankroll: bankroll))
        
        if totalHours < 1 {
            return Int(totalEarnings / (totalMinutes / 60))
        } else {
            return Int(totalEarnings / totalTime)
        }
    }
    
    func bbPerHour(year: String? = nil, range: RangeSelection = .all) -> Double {
        var sessionsArray: [PokerSession]
        
        if let year = year {
            sessionsArray = sessions.filter({ $0.date.getYear() == year })
        } else {
            switch range {
            case .all:
                sessionsArray = sessions
            case .oneMonth:
                sessionsArray = filterSessionsLastMonth().filter { $0.isTournament != true }
            case .sixMonth:
                sessionsArray = filterSessionsLastSixMonths().filter { $0.isTournament != true }
            case .oneYear:
                sessionsArray = filterSessionsLastTwelveMonths().filter { $0.isTournament != true }
            case .ytd:
                sessionsArray = filterSessionsYTD().filter { $0.isTournament != true }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        
        let totalBigBlindRate = sessionsArray.map({ $0.bigBlindPerHour }).reduce(0, +)
        let count = Double(sessionsArray.count)
        
        guard count > 0 else { return 0 }
        
        return totalBigBlindRate / count
    }
    
    func totalHoursPlayed(range: RangeSelection = .all, bankroll: SessionFilter) -> String {
        
        var sessionsArray: [PokerSession] {
            switch bankroll {
            case .all:
                switch range {
                case .all:
                    return sessions
                case .oneMonth:
                    return filterSessionsLastMonth()
                case .sixMonth:
                    return filterSessionsLastSixMonths()
                case .oneYear:
                    return filterSessionsLastTwelveMonths()
                case .ytd:
                    return filterSessionsYTD()
                }
                
            case .cash:
                switch range {
                case .all:
                    return allCashSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter { $0.isTournament != true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter { $0.isTournament != true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }
                case .ytd:
                    return filterSessionsYTD().filter { $0.isTournament != true }
                }
                
            case .tournaments:
                switch range {
                case .all:
                    return allTournamentSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter { $0.isTournament == true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter { $0.isTournament == true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }
                case .ytd:
                    return filterSessionsYTD().filter { $0.isTournament == true }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return "0" }
        let totalHours = sessionsArray.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMins = sessionsArray.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMins)
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    func avgDuration(range: RangeSelection = .all, bankroll: SessionFilter) -> String {
        
        var sessionsArray: [PokerSession] {
            switch bankroll {
            case .all:
                switch range {
                case .all:
                    return sessions
                case .oneMonth:
                    return filterSessionsLastMonth()
                case .sixMonth:
                    return filterSessionsLastSixMonths()
                case .oneYear:
                    return filterSessionsLastTwelveMonths()
                case .ytd:
                    return filterSessionsYTD()
                }
                
            case .cash:
                switch range {
                case .all:
                    return allCashSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter{ $0.isTournament != true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter{ $0.isTournament != true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter{ $0.isTournament != true }
                case .ytd:
                    return filterSessionsYTD().filter{ $0.isTournament != true }
                }
                
            case .tournaments:
                switch range {
                case .all:
                    return allTournamentSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter{ $0.isTournament == true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
                case .ytd:
                    return filterSessionsYTD().filter{ $0.isTournament == true }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return "0" }
        
        let hoursArray: [Int] = sessionsArray.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessionsArray.map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +) / sessionsArray.count
        let totalMinutes = minutesArray.reduce(0, +) / sessionsArray.count
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    func avgProfit(range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        switch bankroll {
        case .all:
            switch range {
            case .all:
                guard !sessions.isEmpty else { return 0 }
                return tallyBankroll(range: .all, bankroll: .all) / sessions.count
            case .oneMonth:
                guard !filterSessionsLastMonth().isEmpty else { return 0 }
                return tallyBankroll(range: .oneMonth, bankroll: .all) / filterSessionsLastMonth().count
            case .sixMonth:
                guard !filterSessionsLastSixMonths().isEmpty else { return 0 }
                return tallyBankroll(range: .oneMonth, bankroll: .all) / filterSessionsLastSixMonths().count
            case .oneYear:
                guard !filterSessionsLastTwelveMonths().isEmpty else { return 0 }
                return tallyBankroll(range: .oneYear, bankroll: .all) / filterSessionsLastTwelveMonths().count
            case .ytd:
                guard !filterSessionsYTD().isEmpty else { return 0 }
                return tallyBankroll(range: .ytd, bankroll: .all) / filterSessionsYTD().count
            }
            
        case .cash:
            switch range {
            case .all:
                guard !allCashSessions().isEmpty else { return 0 }
                return tallyBankroll(range: .all, bankroll: bankroll) / allCashSessions().count
            case .oneMonth:
                guard !filterSessionsLastMonth().filter ({ $0.isTournament != true }).isEmpty else { return 0 }
                return tallyBankroll(range: .oneMonth, bankroll: .cash) / filterSessionsLastMonth().filter ({ $0.isTournament != true }).count
            case .sixMonth:
                guard !filterSessionsLastSixMonths().filter ({ $0.isTournament != true }).isEmpty else { return 0 }
                return tallyBankroll(range: .sixMonth, bankroll: .cash) / filterSessionsLastSixMonths().filter ({ $0.isTournament != true }).count
            case .oneYear:
                guard !filterSessionsLastTwelveMonths().filter ({ $0.isTournament != true }).isEmpty else { return 0 }
                return tallyBankroll(range: .oneYear, bankroll: .cash) / filterSessionsLastTwelveMonths().filter ({ $0.isTournament != true }).count
            case .ytd:
                guard !filterSessionsYTD().filter ({ $0.isTournament != true }).isEmpty else { return 0 }
                return tallyBankroll(range: .ytd, bankroll: .cash) / filterSessionsYTD().filter ({ $0.isTournament != true }).count
            }
            
        case .tournaments:
            guard !allTournamentSessions().isEmpty else { return 0 }
            return tallyBankroll(bankroll: bankroll) / allTournamentSessions().count
        }
    }
    
    func totalWinRate(range: RangeSelection = .all, bankroll: SessionFilter) -> String {
        var sessionsArray: [PokerSession] {
            switch bankroll {
            case .all:
                switch range {
                case .all:
                    return sessions
                case .oneMonth:
                    return filterSessionsLastMonth()
                case .sixMonth:
                    return filterSessionsLastSixMonths()
                case .oneYear:
                    return filterSessionsLastTwelveMonths()
                case .ytd:
                    return filterSessionsYTD()
                }
                
            case .cash:
                switch range {
                case .all:
                    return allCashSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter{ $0.isTournament != true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter{ $0.isTournament != true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter{ $0.isTournament != true }
                case .ytd:
                    return filterSessionsYTD().filter{ $0.isTournament != true }
                }
                
            case .tournaments:
                switch range {
                case .all:
                    return allTournamentSessions()
                case .oneMonth:
                    return filterSessionsLastMonth().filter{ $0.isTournament == true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
                case .ytd:
                    return filterSessionsYTD().filter{ $0.isTournament == true }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return "0%" }
        let profitableSessions = sessionsArray.filter({ $0.profit > 0 }).count
        let winPercentage = Double(profitableSessions) / Double(sessionsArray.count)
        return winPercentage.asPercent()
    }
    
    func numOfCashes(range: RangeSelection = .all) -> Int {
        
        var sessionsArray: [PokerSession] {
            switch range {
            case .all:
                return allCashSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament != true }
            case .sixMonth:
                return filterSessionsLastSixMonths().filter{ $0.isTournament != true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter{ $0.isTournament != true }
            case .ytd:
                return filterSessionsYTD().filter{ $0.isTournament != true }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        return sessionsArray.filter { $0.profit > 0 }.count
    }
    
    func totalHighHands(range: RangeSelection = .all) -> Int {
        var sessionsArray: [PokerSession] {
            switch range {
            case .all:
                return allCashSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter({ $0.isTournament != true })
            case .sixMonth:
                return filterSessionsLastSixMonths().filter({ $0.isTournament != true })
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter({ $0.isTournament != true })
            case .ytd:
                return filterSessionsYTD().filter({ $0.isTournament != true })
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        let highHandTotals = sessionsArray.map({ $0.highHandBonus ?? 0 }).reduce(0,+)
        return highHandTotals
    }
}
