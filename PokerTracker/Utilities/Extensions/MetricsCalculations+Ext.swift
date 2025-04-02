//
//  MetricsCalculations+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/28/24.
//

import Foundation
import SwiftUI

extension SessionsListViewModel {
    
    func countSessions(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all) -> Int {
        
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        let filteredByType: [PokerSession_v2] = {
            switch type {
            case .all:
                return allSessions
            case .cash:
                return allSessions.filter { !$0.isTournament }
            case .tournaments:
                return allSessions.filter { $0.isTournament }
            }
        }()
        
        let result: [PokerSession_v2] = {
            switch range {
            case .all:
                return filteredByType
            case .oneMonth:
                return filteredByType.filter { $0.date >= Calendar.current.date(byAdding: .month, value: -1, to: Date())! }
            case .threeMonth:
                return filteredByType.filter { $0.date >= Calendar.current.date(byAdding: .month, value: -3, to: Date())! }
            case .sixMonth:
                return filteredByType.filter { $0.date >= Calendar.current.date(byAdding: .month, value: -6, to: Date())! }
            case .oneYear:
                return filteredByType.filter { $0.date >= Calendar.current.date(byAdding: .year, value: -1, to: Date())! }
            case .ytd:
                let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
                return filteredByType.filter { $0.date >= startOfYear }
            }
        }()
        
        return result.count
    }
    
    func tallyBankroll(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all, excludingYear: String? = nil) -> Int {
        // Get sessions from the correct source
        let sourceSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        // Time filter
        let dateFiltered: [PokerSession_v2] = {
            let calendar = Calendar.current
            let now = Date()
            
            switch range {
            case .all:
                return sourceSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return sourceSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return sourceSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return sourceSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return sourceSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return sourceSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Optional year exclusion
        let yearFiltered = excludingYear != nil
        ? dateFiltered.filter { $0.date.getYear() != excludingYear }
        : dateFiltered
        
        // Optional session type filtering
        let typeFiltered: [PokerSession_v2] = {
            switch type {
            case .all: return yearFiltered
            case .cash: return yearFiltered.filter { !$0.isTournament }
            case .tournaments: return yearFiltered.filter { $0.isTournament }
            }
        }()
        
        // Return total profit
        return typeFiltered.map(\.profit).reduce(0, +)
    }
    
    func hourlyRate(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all, excludingYear: String? = nil) -> Int {
        
        // Pull correct session data
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        // Apply date range
        let filteredByRange: [PokerSession_v2] = {
            let calendar = Calendar.current
            let now = Date()
            
            switch range {
            case .all: return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Apply optional year exclusion
        let filteredByYear = excludingYear != nil
            ? filteredByRange.filter { $0.date.getYear() != excludingYear }
            : filteredByRange
        
        // Apply session type filter
        let finalSessions: [PokerSession_v2] = {
            switch type {
            case .all: return filteredByYear
            case .cash: return filteredByYear.filter { !$0.isTournament }
            case .tournaments: return filteredByYear.filter { $0.isTournament }
            }
        }()
        
        guard !finalSessions.isEmpty else { return 0 }
        
        // Get total hours and minutes
        let totalHours = Float(finalSessions.compactMap { $0.sessionDuration.hour }.reduce(0, +))
        let totalMinutes = Float(finalSessions.compactMap { $0.sessionDuration.minute }.reduce(0, +))
        
        let totalTime = totalHours + (totalMinutes / 60)
        let totalProfit = Float(finalSessions.map(\.profit).reduce(0, +))
        
        // Avoid divide-by-zero
        guard totalTime > 0 else { return 0 }
        
        return Int(round(totalProfit / totalTime))
    }
    
    func bbPerHour(bankrollID: UUID? = nil, range: RangeSelection = .all, excludingYear: String? = nil) -> Double {
        
        // Get relevant sessions (cash only)
        let sourceSessions: [PokerSession_v2]

        if let id = bankrollID {
            sourceSessions = bankrolls.first(where: { $0.id == id })?.sessions ?? []
        } else {
            sourceSessions = sessions + bankrolls.flatMap(\.sessions)
        }
        
        // Filter out tournaments
        let cashOnly = sourceSessions.filter { !$0.isTournament }
        
        // Apply date range
        let calendar = Calendar.current
        let now = Date()
        
        let rangeFiltered: [PokerSession_v2] = {
            switch range {
            case .all: return cashOnly
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return cashOnly.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return cashOnly.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return cashOnly.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return cashOnly.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return cashOnly.filter { $0.date >= startOfYear }
            }
        }()
        
        // Exclude year if needed
        let sessions = excludingYear != nil
            ? rangeFiltered.filter { $0.date.getYear() != excludingYear }
            : rangeFiltered

        guard !sessions.isEmpty else { return 0 }

        // Time & BBs
        let totalBBs = Float(sessions.map(\.bigBlindsWon).reduce(0, +))
        let totalHours = Float(sessions.compactMap { $0.sessionDuration.hour }.reduce(0, +))
        let totalMinutes = Float(sessions.compactMap { $0.sessionDuration.minute }.reduce(0, +))
        let totalTime = totalHours + (totalMinutes / 60)

        guard totalTime > 0 else { return 0 }
        
        let result = Double(totalBBs / totalTime)
        return (result * 100).rounded() / 100
    }
    
    func avgROI(bankrollID: UUID? = nil, range: RangeSelection = .all) -> String {
        
        // Source sessions (default or specific bankroll)
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        // Apply date filter
        let calendar = Calendar.current
        let now = Date()
        
        let sessionsArray: [PokerSession_v2] = {
            switch range {
            case .all: return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        guard !sessionsArray.isEmpty else { return "0%" }
        
        // Tournaments
        let totalTournamentInvested = sessionsArray
            .filter { $0.isTournament }
            .reduce(0) { $0 + $1.buyIn + (($1.rebuyCount ?? 0) * $1.buyIn) }

        let totalTournamentWinnings = sessionsArray
            .filter { $0.isTournament }
            .reduce(0) { $0 + $1.cashOut }

        // Cash games
        let totalCashGameInvested = sessionsArray
            .filter { !$0.isTournament }
            .reduce(0) { $0 + $1.buyIn }

        let totalCashGameWinnings = sessionsArray
            .filter { !$0.isTournament }
            .reduce(0) { $0 + $1.cashOut }

        // ROI calc
        let totalInvested = totalTournamentInvested + totalCashGameInvested
        let totalWinnings = totalTournamentWinnings + totalCashGameWinnings

        guard totalInvested > 0 else { return "0%" }
        
        let avgROI = (Double(totalWinnings) - Double(totalInvested)) / Double(totalInvested)
        return avgROI.asPercent()
    }
    
    func totalHoursPlayed(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all) -> String {
        
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        let calendar = Calendar.current
        let now = Date()
        
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all: return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        let filteredByType: [PokerSession_v2] = {
            switch type {
            case .all: return filteredByRange
            case .cash: return filteredByRange.filter { !$0.isTournament }
            case .tournaments: return filteredByRange.filter { $0.isTournament }
            }
        }()
        
        guard !filteredByType.isEmpty else { return "0" }
        
        let totalHours = filteredByType.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMinutes = filteredByType.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.durationShortHand()
    }
    
    func handsPlayed(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all) -> Int {
        
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        let calendar = Calendar.current
        let now = Date()
        
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all: return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        let filteredByType: [PokerSession_v2] = {
            switch type {
            case .all: return filteredByRange
            case .cash: return filteredByRange.filter { !$0.isTournament }
            case .tournaments: return filteredByRange.filter { $0.isTournament }
            }
        }()
        
        guard !filteredByType.isEmpty else { return 0 }
        
        let handsPerHourDefault = UserDefaults.standard.object(forKey: "handsPerHourDefault") as? Int ?? 25
        
        let totalHands = filteredByType.reduce(0) { total, session in
            let hours = Float(session.sessionDuration.hour ?? 0)
            let minutes = Float(session.sessionDuration.minute ?? 0)
            let durationInHours = hours + (minutes / 60)
            let hph = session.handsPerHour ?? handsPerHourDefault
            
            return total + Int(durationInHours * Float(hph))
        }
        
        return totalHands
    }
    
    func profitPer100(hands: Int, bankroll: Int) -> Int {
        
        guard hands != 0 else { return 0 }
        return Int(Double(bankroll) / Double(hands) * 100)
    }
    
    func avgDuration(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all) -> String {
        
        // Grab sessions from correct source
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        // Filter by date range
        let calendar = Calendar.current
        let now = Date()
        
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all: return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Filter by session type
        let filteredSessions: [PokerSession_v2] = {
            switch type {
            case .all: return filteredByRange
            case .cash: return filteredByRange.filter { !$0.isTournament }
            case .tournaments: return filteredByRange.filter { $0.isTournament }
            }
        }()
        
        guard !filteredSessions.isEmpty else { return "0" }

        // Average duration
        let totalHours = filteredSessions.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMinutes = filteredSessions.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        
        let avgHours = totalHours / filteredSessions.count
        let avgMinutes = totalMinutes / filteredSessions.count
        
        let dateComponents = DateComponents(hour: avgHours, minute: avgMinutes)
        return dateComponents.durationShortHand()
    }
    
    func avgProfit(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all, excludingYear: String? = nil) -> Int {
        
        // Get session list (default + bankrolls or just one bankroll)
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        let calendar = Calendar.current
        let now = Date()
        
        // Apply range filtering
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all: return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Filter by session type
        let filteredByType: [PokerSession_v2] = {
            switch type {
            case .all: return filteredByRange
            case .cash: return filteredByRange.filter { !$0.isTournament }
            case .tournaments: return filteredByRange.filter { $0.isTournament }
            }
        }()
        
        // Optionally exclude a year
        let finalSessions: [PokerSession_v2] = {
            if let year = excludingYear {
                return filteredByType.filter { $0.date.getYear() != year }
            } else {
                return filteredByType
            }
        }()
        
        guard !finalSessions.isEmpty else { return 0 }
        
        let totalProfit = finalSessions.reduce(0) { $0 + $1.profit }
        return totalProfit / finalSessions.count
    }
    
    func totalWinRate(bankrollID: UUID? = nil, type: SessionFilter = .all, range: RangeSelection = .all, excludingYear: String? = nil) -> Double {
        
        // Source session list
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        let calendar = Calendar.current
        let now = Date()
        
        // Filter by date range
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all: return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Filter by type
        let filteredByType: [PokerSession_v2] = {
            switch type {
            case .all: return filteredByRange
            case .cash: return filteredByRange.filter { !$0.isTournament }
            case .tournaments: return filteredByRange.filter { $0.isTournament }
            }
        }()
        
        // Filter by year (optional)
        let finalSessions: [PokerSession_v2] = {
            if let year = excludingYear {
                return filteredByType.filter { $0.date.getYear() != year }
            } else {
                return filteredByType
            }
        }()
        
        guard !finalSessions.isEmpty else { return 0 }
        
        let profitable = finalSessions.filter { $0.profit > 0 }.count
        return Double(profitable) / Double(finalSessions.count)
    }
    
    func avgTournamentBuyIn(bankrollID: UUID? = nil, range: RangeSelection = .all) -> Int {
        
        // Fetch sessions based on scope
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        guard !allSessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Filter by range
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        let tournamentSessions = filteredByRange.filter { $0.isTournament }
        guard !tournamentSessions.isEmpty else { return 0 }
        
        let totalBuyIns = tournamentSessions.map(\.buyIn).reduce(0, +)
        return totalBuyIns / tournamentSessions.count
    }
    
    func tournamentCount(bankrollID: UUID? = nil, range: RangeSelection = .all) -> Int {
        
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        guard !allSessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Filter by range
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        let tournamentSessions = filteredByRange.filter { $0.isTournament }
        return tournamentSessions.count
    }
    
    func inTheMoneyRatio(bankrollID: UUID? = nil, range: RangeSelection = .all) -> String {
        
        // Fetch all sessions
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        let calendar = Calendar.current
        let now = Date()
        
        // Filter by range
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        let tournamentSessions = filteredByRange.filter { $0.isTournament }
        guard !tournamentSessions.isEmpty else { return "0%" }
        
        let inTheMoneyCount = tournamentSessions.filter { $0.profit > 0 }.count
        let ratio = Double(inTheMoneyCount) / Double(tournamentSessions.count)
        
        return ratio.asPercent()
    }
    
    func bountiesCollected(bankrollID: UUID? = nil, range: RangeSelection = .all) -> Int {
        
        // Load sessions from either default or selected bankroll
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        guard !allSessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let now = Date()
        
        // Apply range filter
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Only look at tournament sessions
        let tournamentSessions = filteredByRange.filter { $0.isTournament }
        guard !tournamentSessions.isEmpty else { return 0 }

        // Sum non-nil bounties
        return tournamentSessions.compactMap(\.bounties).reduce(0, +)
    }
    
    // MARK: COME BACK TO THIS, DEFINITELY NEEDS UPDATING
    func totalActionSold(range: RangeSelection) -> Int {
        guard !allTournamentSessions().isEmpty else { return 0 }
        
        var tournamentArray: [PokerSession_v2] {
            switch range {
            case .all: return allTournamentSessions()
            case .oneMonth: return filterSessionsLastMonth().filter{ $0.isTournament == true }
            case .threeMonth: return filterSessionsLastThreeMonths().filter { $0.isTournament == true }
            case .sixMonth: return filterSessionsLastSixMonths().filter{ $0.isTournament == true }
            case .oneYear: return filterSessionsLastTwelveMonths().filter{ $0.isTournament == true }
            case .ytd: return filterSessionsYTD().filter{ $0.isTournament == true }
            }
        }
        
        let totalPaidOut = tournamentArray.reduce(0) { total, session in
            let cashOut = Double(session.cashOut)
            let bounties = Double(session.bounties ?? 0)
            
            let totalPrizeMoney = cashOut + bounties
            
            let sessionTotalPayout = session.stakers?.reduce(0.0) { payout, staker in
                payout + (totalPrizeMoney * staker.percentage)
            } ?? 0.0
            
            return total + Int(sessionTotalPayout)
        }
        
        return totalPaidOut
    }
    
    func averageTournamentRebuys(bankrollID: UUID? = nil, range: RangeSelection = .all) -> Double {
        
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        let calendar = Calendar.current
        let now = Date()
        
        let filteredRange: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        let tournaments = filteredRange.filter { $0.isTournament }
        guard !tournaments.isEmpty else { return 0 }
        
        let totalRebuys = tournaments.map { $0.rebuyCount ?? 0 }.reduce(0, +)
        return Double(totalRebuys) / Double(tournaments.count)
    }
    
    func tournamentReturnOnInvestment(bankrollID: UUID? = nil, range: RangeSelection = .all) -> String {
        
        // Step 1: Fetch all sessions
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        // Step 2: Filter by date range
        let calendar = Calendar.current
        let now = Date()
        
        let filteredByRange: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        let tournaments = filteredByRange.filter { $0.isTournament }
        guard !tournaments.isEmpty else { return "0%" }
        
        // Step 3: Calculate investment and winnings
        let totalBuyIns = tournaments.reduce(0) { total, session in
            total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
        }
        
        let totalWinnings = tournaments.reduce(0) { total, session in
            total + session.cashOut
        }
        
        guard totalBuyIns > 0 else { return "0%" }
        
        let roi = (Double(totalWinnings) - Double(totalBuyIns)) / Double(totalBuyIns)
        return roi.asPercent()
    }
    
    func numOfCashes(bankrollID: UUID? = nil, range: RangeSelection = .all) -> Int {
        
        // Step 1: Get sessions from the right source
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        // Step 2: Filter by date range
        let calendar = Calendar.current
        let now = Date()
        
        let filtered: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Step 3: Count profitable cash sessions
        return filtered.filter { !$0.isTournament && $0.profit > 0 }.count
    }
    
    func totalHighHands(bankrollID: UUID? = nil, range: RangeSelection = .all) -> Int {
        
        // Step 1: Get sessions from either a specific or all bankrolls
        let allSessions: [PokerSession_v2] = {
            if let id = bankrollID {
                return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            } else {
                return sessions + bankrolls.flatMap(\.sessions)
            }
        }()
        
        // Step 2: Filter by date range
        let calendar = Calendar.current
        let now = Date()
        
        let filtered: [PokerSession_v2] = {
            switch range {
            case .all:
                return allSessions
            case .oneMonth:
                let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .threeMonth:
                let cutoff = calendar.date(byAdding: .month, value: -3, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .sixMonth:
                let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .oneYear:
                let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
                return allSessions.filter { $0.date >= cutoff }
            case .ytd:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        // Step 3: Only include cash games and sum highHandBonus
        let cashSessions = filtered.filter { !$0.isTournament }
        return cashSessions.map { $0.highHandBonus }.reduce(0, +)
    }
}
