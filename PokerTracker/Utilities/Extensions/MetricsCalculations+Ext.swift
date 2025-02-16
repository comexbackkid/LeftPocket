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
            case .all: return sessions.count
            case .oneMonth: return filterSessionsLastMonth().count
            case .threeMonth: return filterSessionsLastThreeMonths().count
            case .sixMonth: return filterSessionsLastSixMonths().count
            case .oneYear: return filterSessionsLastTwelveMonths().count
            case .ytd: return filterSessionsYTD().count
            }
        case .cash:
            switch range {
            case .all: return allCashSessions().count
            case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament != true }.count
            case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament != true }.count
            case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament != true }.count
            case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }.count
            case .ytd: return filterSessionsYTD().filter { $0.isTournament != true }.count
            }
        case .tournaments:
            switch range {
            case .all: return allTournamentSessions().count
            case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament == true }.count
            case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament == true }.count
            case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament == true }.count
            case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }.count
            case .ytd: return filterSessionsYTD().filter { $0.isTournament == true }.count
            }
        }
    }
    
    func tallyBankroll(yearExcluded: String? = nil, range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        
        if let yearExcluded = yearExcluded {
            return sessions.filter({ $0.date.getYear() != yearExcluded }).map { Int($0.profit) }.reduce(0, +)
            
        } else  {
            switch bankroll {
            case .all:
                switch range {
                case .all: return sessions.map { Int($0.profit) }.reduce(0, +)
                case .oneMonth: return filterSessionsLastMonth().map { Int($0.profit) }.reduce(0, +)
                case .threeMonth: return filterSessionsLastThreeMonths().map { Int($0.profit) }.reduce(0, +)
                case .sixMonth: return filterSessionsLastSixMonths().map { Int($0.profit) }.reduce(0, +)
                case .oneYear: return filterSessionsLastTwelveMonths().map { Int($0.profit) }.reduce(0, +)
                case .ytd: return filterSessionsYTD().map { Int($0.profit) }.reduce(0, +)
                }
                
            case .cash:
                switch range {
                case .all: return allCashSessions().map { Int($0.profit) }.reduce(0, +)
                case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
                case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
                case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
                case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
                case .ytd: return filterSessionsYTD().filter { $0.isTournament != true }.map { Int($0.profit) }.reduce(0, +)
                }
                
            case .tournaments:
                switch range {
                case .all: return allTournamentSessions().map { Int($0.profit) }.reduce(0, +)
                case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
                case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
                case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
                case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
                case .ytd: return filterSessionsYTD().filter { $0.isTournament == true }.map { Int($0.profit) }.reduce(0, +)
                }
            }
        }
    }
    
    func hourlyRate(yearExcluded: String? = nil, range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        
        var sessionsArray: [PokerSession_v2] {
            
            if let yearExcluded = yearExcluded {
                return sessions.filter({ $0.date.getYear() != yearExcluded })
            } else {
                switch bankroll {
                case .all:
                    switch range {
                    case .all: return sessions
                    case .oneMonth: return filterSessionsLastMonth()
                    case .threeMonth: return filterSessionsLastThreeMonths()
                    case .sixMonth: return filterSessionsLastSixMonths()
                    case .oneYear: return filterSessionsLastTwelveMonths()
                    case .ytd: return filterSessionsYTD()
                    }
                    
                case .cash:
                    switch range {
                    case .all: return allCashSessions()
                    case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament != true }
                    case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament != true }
                    case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament != true }
                    case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }
                    case .ytd: return filterSessionsYTD().filter { $0.isTournament != true }
                    }
                    
                case .tournaments:
                    switch range {
                    case .all: return allTournamentSessions()
                    case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament == true }
                    case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
                    case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament == true }
                    case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }
                    case .ytd: return filterSessionsYTD().filter { $0.isTournament == true }
                    }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        
        let totalHours = Float(sessionsArray.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+))
        let totalMinutes = Float(sessionsArray.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
        
        // Add up all the hours & minutes together to simply get a sum of hours
        let totalTime = totalHours + (totalMinutes / 60)
        let totalEarnings = Float(tallyBankroll(yearExcluded: yearExcluded, range: range, bankroll: bankroll))
        
        if totalHours < 1 {
            return Int(round(totalEarnings / (totalMinutes / 60)))
        } else {
            return Int(round(totalEarnings / totalTime))
        }
    }
    
    func bbPerHour(yearExcluded: String? = nil, range: RangeSelection = .all) -> Double {
        var sessionsArray: [PokerSession_v2]
        
        if let yearExcluded = yearExcluded {
            sessionsArray = sessions.filter({ $0.date.getYear() != yearExcluded })
            
        } else {
            switch range {
            case .all: sessionsArray = sessions.filter { $0.isTournament != true }
            case .oneMonth: sessionsArray = filterSessionsLastMonth().filter { $0.isTournament != true }
            case .threeMonth: sessionsArray = filterSessionsLastThreeMonths().filter { $0.isTournament != true }
            case .sixMonth: sessionsArray = filterSessionsLastSixMonths().filter { $0.isTournament != true }
            case .oneYear: sessionsArray = filterSessionsLastTwelveMonths().filter { $0.isTournament != true }
            case .ytd: sessionsArray = filterSessionsYTD().filter { $0.isTournament != true }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        let totalBigBlindsWon = Float(sessionsArray.map({ $0.bigBlindsWon }).reduce(0, +))
        let totalHours = Float(sessionsArray.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+))
        let totalMinutes = Float(sessionsArray.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
        let totalTime = totalHours + (totalMinutes / 60)
        let result = Double(totalBigBlindsWon / totalTime)
        return (result * 100).rounded() / 100
    }
    
    func avgROI(range: RangeSelection = .all) -> String {
        
        var sessionsArray: [PokerSession_v2] {
            switch range {
            case .all: return sessions
            case .oneMonth: return filterSessionsLastMonth()
            case .threeMonth: return filterSessionsLastThreeMonths()
            case .sixMonth: return filterSessionsLastSixMonths()
            case .oneYear: return filterSessionsLastTwelveMonths()
            case .ytd: return filterSessionsYTD()
            }
        }
        
        guard !sessionsArray.isEmpty else { return "0" }
        
        // Calculate total invested and winnings for tournaments
        let totalTournamentInvested = sessionsArray
            .filter { $0.isTournament }
            .reduce(0) { total, session in
                total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
            }
        
        let totalTournamentWinnings = sessionsArray
            .filter { $0.isTournament }
            .reduce(0) { total, session in
                total + session.cashOut
            }
        
        // Calculate total invested and winnings for cash games
        let totalCashGameInvested = sessionsArray
            .filter { !$0.isTournament }
            .reduce(0) { total, session in
                total + session.buyIn
            }
        
        let totalCashGameWinnings = sessionsArray
            .filter { !$0.isTournament }
            .reduce(0) { total, session in
                total + session.cashOut
            }
        
        // Combine totals
        let totalInvested = totalTournamentInvested + totalCashGameInvested
        let totalWinnings = totalTournamentWinnings + totalCashGameWinnings
        
        // Calculate average ROI
        guard totalInvested > 0 else { return "0%" }
        let avgROI = (Double(totalWinnings) - Double(totalInvested)) / Double(totalInvested)
        return avgROI.asPercent()
    }
    
    func totalHoursPlayed(range: RangeSelection = .all, bankroll: SessionFilter) -> String {
        
        var sessionsArray: [PokerSession_v2] {
            switch bankroll {
            case .all:
                switch range {
                case .all: return sessions
                case .oneMonth: return filterSessionsLastMonth()
                case .threeMonth: return filterSessionsLastThreeMonths()
                case .sixMonth: return filterSessionsLastSixMonths()
                case .oneYear: return filterSessionsLastTwelveMonths()
                case .ytd: return filterSessionsYTD()
                }
                
            case .cash:
                switch range {
                case .all: return allCashSessions()
                case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament != true }
                case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament != true }
                case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament != true }
                case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }
                case .ytd: return filterSessionsYTD().filter { $0.isTournament != true }
                }
                
            case .tournaments:
                switch range {
                case .all: return allTournamentSessions()
                case .oneMonth: return filterSessionsLastMonth().filter { $0.isTournament == true }
                case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
                case .sixMonth: return filterSessionsLastSixMonths().filter { $0.isTournament == true }
                case .oneYear: return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }
                case .ytd: return filterSessionsYTD().filter { $0.isTournament == true }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return "0" }
        let totalHours = sessionsArray.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMins = sessionsArray.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMins)
        return dateComponents.durationShortHand()
    }
    
    func handsPlayed(range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        
        var sessionsArray: [PokerSession_v2] {
            switch bankroll {
            case .all:
                switch range {
                case .all:
                    return sessions
                case .oneMonth:
                    return filterSessionsLastMonth()
                case .threeMonth:
                    return filterSessionsLastThreeMonths()
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
                case .threeMonth:
                    return filterSessionsLastThreeMonths().filter { $0.isTournament != true }
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
                case .threeMonth:
                    return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
                case .sixMonth:
                    return filterSessionsLastSixMonths().filter { $0.isTournament == true }
                case .oneYear:
                    return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }
                case .ytd:
                    return filterSessionsYTD().filter { $0.isTournament == true }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        let totalHours = Float(sessionsArray.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+))
        let totalMinutes = Float(sessionsArray.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
        
        // Add up all the hours & minutes together to simply get a sum of hours
        let totalTime = totalHours + (totalMinutes / 60)
        let handsPerHour = UserDefaults.standard.object(forKey: "handsPerHourDefault") as? Int ?? 25
        let totalHands = Int(round(totalTime)) * handsPerHour
        return totalHands
    }
    
    func profitPer100(hands: Int, bankroll: Int) -> Int {
        
        guard hands != 0 else { return 0 }
        return Int(Double(bankroll) / Double(hands) * 100)
    }
    
    func avgDuration(range: RangeSelection = .all, bankroll: SessionFilter) -> String {
        
        var sessionsArray: [PokerSession_v2] {
            switch bankroll {
            case .all:
                switch range {
                case .all:
                    return sessions
                case .oneMonth:
                    return filterSessionsLastMonth()
                case .threeMonth:
                    return filterSessionsLastThreeMonths()
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
                case .threeMonth:
                    return filterSessionsLastThreeMonths().filter { $0.isTournament != true }
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
                case .threeMonth:
                    return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
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
        
        let hoursArray: [Int] = sessionsArray.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessionsArray.map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +) / sessionsArray.count
        let totalMinutes = minutesArray.reduce(0, +) / sessionsArray.count
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.durationShortHand()
    }
    
    func avgProfit(yearExcluded: String? = nil, range: RangeSelection = .all, bankroll: SessionFilter) -> Int {
        
        if let yearExcluded = yearExcluded {
            guard !sessions.filter({ $0.date.getYear() != yearExcluded }).isEmpty else { return 0 }
            return tallyBankroll(yearExcluded: yearExcluded, bankroll: .all) / sessions.filter({ $0.date.getYear() != yearExcluded }).count
        } else {
            switch bankroll {
            case .all:
                switch range {
                case .all:
                    guard !sessions.isEmpty else { return 0 }
                    return tallyBankroll(range: .all, bankroll: .all) / sessions.count
                case .oneMonth:
                    guard !filterSessionsLastMonth().isEmpty else { return 0 }
                    return tallyBankroll(range: .oneMonth, bankroll: .all) / filterSessionsLastMonth().count
                case .threeMonth:
                    guard !filterSessionsLastThreeMonths().isEmpty else { return 0 }
                    return tallyBankroll(range: .threeMonth, bankroll: .all) / filterSessionsLastThreeMonths().count
                case .sixMonth:
                    guard !filterSessionsLastSixMonths().isEmpty else { return 0 }
                    return tallyBankroll(range: .sixMonth, bankroll: .all) / filterSessionsLastSixMonths().count
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
                case .threeMonth:
                    guard !filterSessionsLastThreeMonths().filter({ $0.isTournament != true }).isEmpty else { return 0 }
                    return tallyBankroll(range: .threeMonth, bankroll: .cash) / filterSessionsLastThreeMonths().filter({ $0.isTournament != true  }).count
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
        
        
    }
    
    func totalWinRate(yearExcluded: String? = nil, range: RangeSelection = .all, bankroll: SessionFilter) -> Double {
        var sessionsArray: [PokerSession_v2] {
            
            if let yearExcluded = yearExcluded {
                return sessions.filter({ $0.date.getYear() != yearExcluded })
            } else {
                switch bankroll {
                case .all:
                    switch range {
                    case .all:
                        return sessions
                    case .oneMonth:
                        return filterSessionsLastMonth()
                    case .threeMonth:
                        return filterSessionsLastThreeMonths()
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
                    case .threeMonth:
                        return filterSessionsLastThreeMonths().filter { $0.isTournament != true }
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
                    case .threeMonth:
                        return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
                    case .sixMonth:
                        return filterSessionsLastSixMonths().filter { $0.isTournament == true }
                    case .oneYear:
                        return filterSessionsLastTwelveMonths().filter { $0.isTournament == true }
                    case .ytd:
                        return filterSessionsYTD().filter { $0.isTournament == true }
                    }
                }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        let profitableSessions = sessionsArray.filter({ $0.profit > 0 }).count
        let winPercentage = Double(profitableSessions) / Double(sessionsArray.count)
        return winPercentage
    }
    
    func avgTournamentBuyIn(range: RangeSelection) -> Int {
        guard !sessions.isEmpty else { return 0 }
        guard sessions.contains(where: { $0.isTournament == true }) else {
            return 0
        }
        
        var tournamentArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allTournamentSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament == true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .sixMonth:
                return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
            case .ytd:
                return filterSessionsYTD().filter{ $0.isTournament == true }
            }
        }
        
        let tournamentBuyIns = tournamentArray.map { $0.buyIn }.reduce(0, +)
        let count = tournamentArray.count
        
        return tournamentBuyIns / count
    }
    
    func tournamentCount(range: RangeSelection) -> Int {
        guard !sessions.isEmpty else { return 0 }
        guard sessions.contains(where: { $0.isTournament == true }) else {
            return 0
        }
        
        var tournamentArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allTournamentSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament == true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .sixMonth:
                return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
            case .ytd:
                return filterSessionsYTD().filter{ $0.isTournament == true }
            }
        }
        
        return tournamentArray.count
    }
    
    func inTheMoneyRatio(range: RangeSelection) -> String {
        guard !allTournamentSessions().isEmpty else { return "0%" }
        
        var tournamentArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allTournamentSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament == true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .sixMonth:
                return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
            case .ytd:
                return filterSessionsYTD().filter{ $0.isTournament == true }
            }
        }
        
        let tournamentWins = tournamentArray.filter({ $0.profit > 0 }).count
        let totalTournaments = tournamentArray.count
        let winRatio = Double(tournamentWins) / Double(totalTournaments)
        return winRatio.asPercent()
    }
    
    func bountiesCollected(range: RangeSelection) -> Int {
        guard !allTournamentSessions().isEmpty else { return 0 }
        
        var tournamentArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allTournamentSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament == true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .sixMonth:
                return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
            case .ytd:
                return filterSessionsYTD().filter{ $0.isTournament == true }
            }
        }
        
        let bountiesCollected = tournamentArray.compactMap { $0.bounties }.reduce(0, +)
        return bountiesCollected
    }
    
    func averageTournamentRebuys(range: RangeSelection) -> Double {
        guard !allTournamentSessions().isEmpty else { return 0 }
        
        var tournamentArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allTournamentSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament == true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .sixMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
            case .ytd:
                return filterSessionsYTD().filter{ $0.isTournament == true }
            }
        }
        
        let totalRebuys = Double(tournamentArray.map({ $0.rebuyCount ?? 0 }).reduce(0, +))
        let totalTournaments = Double(tournamentArray.count)
        return totalRebuys / totalTournaments
    }
    
    func tournamentReturnOnInvestment(range: RangeSelection) -> String {
        guard !allTournamentSessions().isEmpty else { return "0%" }
        
        var tournamentArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allTournamentSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament == true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .sixMonth:
                return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
            case .ytd:
                return filterSessionsYTD().filter{ $0.isTournament == true }
            }
        }
        
        // Calculate total invested (buy-ins + rebuys)
        let totalBuyIns = tournamentArray.reduce(0) { total, session in
            total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
        }
        
        // Calculate total winnings (gross)
        let totalWinnings = tournamentArray.reduce(0) { total, session in
            total + session.cashOut
        }
        
        // Calculate ROI
        guard totalBuyIns > 0 else { return "0%" }
        let returnOnInvestment = (Double(totalWinnings) - Double(totalBuyIns)) / Double(totalBuyIns)
        
        return returnOnInvestment.asPercent()
    }
    
    func numOfCashes(range: RangeSelection = .all) -> Int {
        
        var sessionsArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allCashSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter{ $0.isTournament != true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament != true }
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
        var sessionsArray: [PokerSession_v2] {
            switch range {
            case .all:
                return allCashSessions()
            case .oneMonth:
                return filterSessionsLastMonth().filter { $0.isTournament != true }
            case .threeMonth:
                return filterSessionsLastThreeMonths().filter { $0.isTournament != true }
            case .sixMonth:
                return filterSessionsLastSixMonths().filter { $0.isTournament != true }
            case .oneYear:
                return filterSessionsLastTwelveMonths().filter { $0.isTournament != true }
            case .ytd:
                return filterSessionsYTD().filter { $0.isTournament != true }
            }
        }
        
        guard !sessionsArray.isEmpty else { return 0 }
        let highHandTotals = sessionsArray.map({ $0.highHandBonus }).reduce(0,+)
        return highHandTotals
    }
}
