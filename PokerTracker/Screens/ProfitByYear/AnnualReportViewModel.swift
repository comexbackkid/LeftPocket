//
//  ProfitByYearViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/6/22.
//

import SwiftUI

class AnnualReportViewModel: ObservableObject {
    
    @ObservedObject var vm = SessionsListViewModel()
    @Published var pickerSelection: PickerTimeline = .ytd
    
    let ytd = Date().getYear()
    let lastYear = Date().modifyDays(days: -365).getYear()
    
    enum PickerTimeline: String, CaseIterable {
        case ytd = "YTD"
        case lastYear
        
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }
    
    /// Each of these functions handle logic in the Annual Report View
    /// Recently simplified by removing from the primary SessionsListViewModel
    /// Long code, but felt it was better to navigate having one long function versus multiple smaller ones
    
    func chartRange(timeline: PickerTimeline, sessionFilter: SessionFilter) -> [PokerSession_v2] {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                vm.allSessionDataByYear(year: ytd)
            case .lastYear:
                vm.allSessionDataByYear(year: lastYear)
            }
        case .cash:
            switch timeline {
            case .ytd:
                vm.allCashSessions().filter({ $0.date.getYear() == ytd })
            case .lastYear:
                vm.allCashSessions().filter({ $0.date.getYear() == lastYear })
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                vm.allTournamentSessions().filter({ $0.date.getYear() == ytd })
            case .lastYear:
                vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear })
            }
        }
    }
    
    func grossIncome(timeline: PickerTimeline, sessionFilter: SessionFilter) -> Int {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let netProfit = vm.sessions.filter({ $0.date.getYear() == ytd }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.sessions.filter({ $0.date.getYear() == ytd }).map { Int($0.expenses) }.reduce(0, +)
                let tournamentBuyIns = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                let grossIncome = netProfit + totalExpenses + tournamentBuyIns
                return grossIncome
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let netProfit = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.expenses) }.reduce(0, +)
                let tournamentBuyIns = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                let grossIncome = netProfit + totalExpenses + tournamentBuyIns
                return grossIncome
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let netProfit = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { Int($0.expenses) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let netProfit = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { Int($0.expenses) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let netProfit = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).map { Int($0.profit) }.reduce(0, +)
                let buyIns = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                let grossIncome = netProfit + buyIns
                return grossIncome
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let netProfit = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { Int($0.profit) }.reduce(0, +)
                let buyIns = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear}).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                let grossIncome = netProfit + buyIns
                return grossIncome
            }
        }
    }
    
    func hourlyCalc(timeline: PickerTimeline, sessionFilter: SessionFilter) -> Int {
        switch timeline {
        case .ytd:
            guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
            let totalHours = Float(vm.sessions.filter({ $0.date.getYear() == ytd }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+))
            let totalMinutes = Float(vm.sessions.filter({ $0.date.getYear() == ytd }).map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
            let totalTime = totalHours + (totalMinutes / 60)
            let totalEarnings = Float(vm.bankrollByYear(year: ytd, sessionFilter: sessionFilter))
            
            if totalHours < 1 {
                return Int(round(totalEarnings / (totalMinutes / 60)))
            } else {
                return Int(round(totalEarnings / totalTime))
            }
        case .lastYear:
            guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
            let totalHours = Float(vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+))
            let totalMinutes = Float(vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
            let totalTime = totalHours + (totalMinutes / 60)
            let totalEarnings = Float(vm.bankrollByYear(year: lastYear, sessionFilter: sessionFilter))
            
            if totalHours < 1 {
                return Int(Float(vm.bankrollByYear(year: lastYear, sessionFilter: sessionFilter)) / (totalMinutes / 60))
            } else {
                return Int(totalEarnings / totalTime)
            }
        }
    }
    
    func avgProfit(timeline: PickerTimeline, sessionFilter: SessionFilter) -> Int {
        switch timeline {
        case .ytd:
            guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
            return vm.bankrollByYear(year: ytd, sessionFilter: sessionFilter) / vm.sessions.filter({ $0.date.getYear() == ytd }).count
        case .lastYear:
            guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
            return vm.bankrollByYear(year: lastYear, sessionFilter: sessionFilter) / vm.sessions.filter({ $0.date.getYear() == lastYear }).count
        }
    }
    
    func winRatio(timeline: PickerTimeline, sessionFilter: SessionFilter) -> String {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return "0%" }
                let wins = Double(vm.numOfCashesByYear(year: ytd))
                let sessions = Double(vm.sessionsPerYear(year: ytd))
                let winPercentage = wins / sessions
                return winPercentage.asPercent()
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0%" }
                let wins = Double(vm.numOfCashesByYear(year: lastYear))
                let sessions = Double(vm.sessionsPerYear(year: lastYear))
                let winPercentage = wins / sessions
                return winPercentage.asPercent()
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return "0%" }
                let wins = Double(vm.allCashSessions().filter({ $0.date.getYear() == ytd && $0.profit > 0 }).count)
                let sessions = Double(vm.allCashSessions().filter({ $0.date.getYear() == ytd }).count)
                let winPercentage = wins / sessions
                return winPercentage.asPercent()
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0%" }
                let wins = Double(vm.allCashSessions().filter({ $0.date.getYear() == lastYear && $0.profit > 0 }).count)
                let sessions = Double(vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).count)
                let winPercentage = wins / sessions
                return winPercentage.asPercent()
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return "0%" }
                let wins = Double(vm.allTournamentSessions().filter({ $0.date.getYear() == ytd && $0.profit > 0 }).count)
                let sessions = Double(vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).count)
                let winPercentage = wins / sessions
                return winPercentage.asPercent()
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0%" }
                let wins = Double(vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear && $0.profit > 0 }).count)
                let sessions = Double(vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).count)
                let winPercentage = wins / sessions
                return winPercentage.asPercent()
            }
        }
    }
    
    func expensesByYear(timeline: PickerTimeline, sessionFilter: SessionFilter) -> Int {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let cashGameExpenses = vm.sessions.filter({ $0.date.getYear() == ytd }).map { $0.expenses }.reduce(0,+)
                let offTableExpenses = vm.transactions.filter({ $0.type == .expense && $0.date.getYear() == ytd }).map { $0.amount }.reduce(0,+)
                let totalTournamentBuyIns = vm.sessions.filter({ $0.isTournament == true }).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                return cashGameExpenses + abs(offTableExpenses) + totalTournamentBuyIns
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let cashGameExpenses = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { $0.expenses }.reduce(0,+)
                let offTableExpenses = vm.transactions.filter({ $0.type == .expense && $0.date.getYear() == lastYear }).map { $0.amount }.reduce(0,+)
                let totalTournamentBuyIns = vm.sessions.filter({ $0.isTournament == true }).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                return cashGameExpenses + abs(offTableExpenses) + totalTournamentBuyIns
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let expenses = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { $0.expenses }.reduce(0,+)
                return expenses
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let expenses = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { $0.expenses }.reduce(0,+)
                return expenses
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let buyIns = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                return buyIns
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let buyIns = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).reduce(0) { total, session in
                    total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                }
                return buyIns
            }
        }
    }
    
    func totalHours(timeline: PickerTimeline, sessionFilter: SessionFilter) -> String {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.sessions.filter({ $0.date.getYear() == ytd }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.sessions.filter({ $0.date.getYear() == ytd }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.durationShortHand()
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.durationShortHand()
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.durationShortHand()
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.durationShortHand()
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.durationShortHand()
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.durationShortHand()
            }
        }
    }
    
    func sessionsPerYear(timeline: PickerTimeline, sessionFilter: SessionFilter) -> String {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                return String(vm.sessionsPerYear(year: Date().getYear()))
            case .lastYear:
                return String(vm.sessionsPerYear(year: lastYear))
            }
        case .cash:
            switch timeline {
            case .ytd:
                return String(vm.allCashSessions().filter({ $0.date.getYear() == ytd }).count)
            case .lastYear:
                return String(vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).count)
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                return String(vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).count)
            case .lastYear:
                return String(vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).count)
            }
        }
    }
    
    func returnOnInvestmentPerYear(timeline: PickerTimeline, sessionFilter: SessionFilter) -> String {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return "0%" }
                return vm.tournamentROIbyYear(year: ytd)
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0%" }
                return vm.tournamentROIbyYear(year: lastYear)
            }
            
        // Cash won't be used
        case .cash:
            return "0%"
            
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return "0%" }
                return vm.tournamentROIbyYear(year: ytd)
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0%" }
                return vm.tournamentROIbyYear(year: lastYear)
            }
        }
    }
    
    func bestLocation(timeline: PickerTimeline, sessionFilter: SessionFilter) -> LocationModel_v2? {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return DefaultData.defaultLocation }
                let filteredSessions = vm.sessions.filter({ $0.date.getYear() == ytd }).map({ ($0.location, $0.profit) })
                let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
                return maxProfit?.key
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return DefaultData.defaultLocation }
                let filteredSessions = vm.sessions.filter({ $0.date.getYear() == lastYear }).map({ ($0.location, $0.profit) })
                let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
                return maxProfit?.key
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return DefaultData.defaultLocation }
                let filteredSessions = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map({ ($0.location, $0.profit) })
                let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
                return maxProfit?.key
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return DefaultData.defaultLocation }
                let filteredSessions = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map({ ($0.location, $0.profit) })
                let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
                return maxProfit?.key
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return DefaultData.defaultLocation }
                let filteredSessions = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).map({ ($0.location, $0.profit) })
                let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
                return maxProfit?.key
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return DefaultData.defaultLocation }
                let filteredSessions = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map({ ($0.location, $0.profit) })
                let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
                return maxProfit?.key
            }
        }
    }
    
    func bestProfit(timeline: PickerTimeline, sessionFilter: SessionFilter) -> Int {
        switch timeline {
        case .ytd:
            return vm.bestSession(year: ytd, sessionFilter: sessionFilter) ?? 0
        case .lastYear:
            return vm.bestSession(year: lastYear, sessionFilter: sessionFilter) ?? 0
        }
    }
    
    func highHandTotals(timeline: PickerTimeline, sessionFilter: SessionFilter) -> Int {
        switch sessionFilter {
        case .all:
            switch timeline {
            case .ytd:
                guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                return vm.sessions.filter({ $0.date.getYear() == ytd }).map { $0.highHandBonus }.reduce(0,+)
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                return vm.sessions.filter({ $0.date.getYear() == lastYear }).map { $0.highHandBonus }.reduce(0,+)
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                return vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { $0.highHandBonus }.reduce(0,+)
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                return vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { $0.highHandBonus }.reduce(0,+)
            }
        case .tournaments:
            return 0
        }
    }
}

extension SessionsListViewModel {
    
    func numOfCashesByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let profitableSessions = sessions.filter({ $0.date.getYear() == year }).filter { $0.profit > 0 }
        return profitableSessions.count
    }
    
    func tournamentROIbyYear(year: String) -> String {
            let filteredSessions = allTournamentSessions().filter { session in
                session.isTournament && session.date.getYear() == year
            }
            
            guard !filteredSessions.isEmpty else { return "0%" }
            
            // Calculate total buy-ins (including rebuys)
            let totalBuyIns = filteredSessions.reduce(0) { total, session in
                total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
            }
            
            // Calculate total winnings (gross)
            let totalWinnings = filteredSessions.reduce(0) { total, session in
                total + session.cashOut
            }
            
            // Calculate ROI
            guard totalBuyIns > 0 else { return "0%" }
            let returnOnInvestment = (Double(totalWinnings) - Double(totalBuyIns)) / Double(totalBuyIns)
            return returnOnInvestment.asPercent()
    }
    
    func allSessionDataByYear(year: String) -> [PokerSession_v2] {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return [] }
        return sessions.filter({ $0.date.getYear() == year })
    }
    
    func grossIncome() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let netProfit = sessions.map { Int($0.profit) }.reduce(0, +)
        let totalExpenses = sessions.map { Int($0.expenses) }.reduce(0, +)
        let grossIncome = netProfit + totalExpenses
        return grossIncome
    }
    
    func totalExpenses() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let expenses = sessions.map { $0.expenses }.reduce(0,+)
        return expenses
    }
}
