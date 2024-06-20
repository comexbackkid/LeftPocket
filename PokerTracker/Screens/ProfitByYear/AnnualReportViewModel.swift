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
    
    // Each of these functions handle logic in the Annual Report View
    // Recently simplified by removing from the primary SessionsListViewModel
    // Long code, but felt it was better to navigate having one long function versus multiple smaller ones
    
    func chartRange(timeline: PickerTimeline, sessionFilter: SessionFilter) -> [PokerSession] {
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
                let totalExpenses = vm.sessions.filter({ $0.date.getYear() == ytd }).map { Int($0.expenses ?? 0) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let netProfit = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.expenses ?? 0) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let netProfit = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { Int($0.expenses ?? 0) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let netProfit = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { Int($0.expenses ?? 0) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let netProfit = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).map { Int($0.expenses ?? 0) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let netProfit = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { Int($0.profit) }.reduce(0, +)
                let totalExpenses = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { Int($0.expenses ?? 0) }.reduce(0, +)
                let grossIncome = netProfit + totalExpenses
                return grossIncome
            }
        }
    }
    
    func hourlyCalc(timeline: PickerTimeline, sessionFilter: SessionFilter) -> Int {
        switch timeline {
        case .ytd:
            guard !vm.sessions.filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
            let hoursArray = vm.sessions.filter({ $0.date.getYear() == ytd }).map { Int($0.sessionDuration.hour ?? 0) }
            let minutesArray = vm.sessions.filter({ $0.date.getYear() == ytd }).map { Int($0.sessionDuration.minute ?? 0) }
            let totalHours = hoursArray.reduce(0,+)
            let totalMinutes = Float(minutesArray.reduce(0, +))
            
            if totalHours < 1 {
                return Int(Float(vm.bankrollByYear(year: ytd, sessionFilter: sessionFilter)) / (totalMinutes / 60))
            } else {
                return vm.bankrollByYear(year: ytd, sessionFilter: sessionFilter) / totalHours
            }
        case .lastYear:
            guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
            let hoursArray = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.sessionDuration.hour ?? 0) }
            let minutesArray = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { Int($0.sessionDuration.minute ?? 0) }
            let totalHours = hoursArray.reduce(0,+)
            let totalMinutes = Float(minutesArray.reduce(0, +))
            
            if totalHours < 1 {
                return Int(Float(vm.bankrollByYear(year: lastYear, sessionFilter: sessionFilter)) / (totalMinutes / 60))
            } else {
                return vm.bankrollByYear(year: lastYear, sessionFilter: sessionFilter) / totalHours
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
                let expenses = vm.sessions.filter({ $0.date.getYear() == ytd }).map { $0.expenses ?? 0 }.reduce(0,+)
                return expenses
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let expenses = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { $0.expenses ?? 0 }.reduce(0,+)
                return expenses
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let expenses = vm.allCashSessions().filter({ $0.date.getYear() == ytd }).map { $0.expenses ?? 0 }.reduce(0,+)
                return expenses
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let expenses = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { $0.expenses ?? 0 }.reduce(0,+)
                return expenses
            }
        case .tournaments:
            switch timeline {
            case .ytd:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                let expenses = vm.allTournamentSessions().filter({ $0.date.getYear() == ytd }).map { $0.expenses ?? 0 }.reduce(0,+)
                return expenses
            case .lastYear:
                guard !vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                let expenses = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { $0.expenses ?? 0 }.reduce(0,+)
                return expenses
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
                return dateComponents.abbreviated(duration: dateComponents)
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.sessions.filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.abbreviated(duration: dateComponents)
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
                return dateComponents.abbreviated(duration: dateComponents)
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.abbreviated(duration: dateComponents)
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
                return dateComponents.abbreviated(duration: dateComponents)
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return "0" }
                let hoursArray: [Int] = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.hour ?? 0 }
                let minutesArray: [Int] = vm.allTournamentSessions().filter({ $0.date.getYear() == lastYear }).map { $0.sessionDuration.minute ?? 0 }
                let totalHours = hoursArray.reduce(0, +)
                let totalMinutes = minutesArray.reduce(0, +)
                let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
                return dateComponents.abbreviated(duration: dateComponents)
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
    
    func bestLocation(timeline: PickerTimeline, sessionFilter: SessionFilter) -> LocationModel? {
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
                return vm.sessions.filter({ $0.date.getYear() == ytd && $0.highHandBonus != nil }).map { $0.highHandBonus ?? 0 }.reduce(0,+)
            case .lastYear:
                guard !vm.sessions.filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                return vm.sessions.filter({ $0.date.getYear() == lastYear && $0.highHandBonus != nil }).map { $0.highHandBonus ?? 0 }.reduce(0,+)
            }
        case .cash:
            switch timeline {
            case .ytd:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == ytd }).isEmpty else { return 0 }
                return vm.allCashSessions().filter({ $0.date.getYear() == ytd && $0.highHandBonus != nil }).map { $0.highHandBonus ?? 0 }.reduce(0,+)
            case .lastYear:
                guard !vm.allCashSessions().filter({ $0.date.getYear() == lastYear }).isEmpty else { return 0 }
                return vm.allCashSessions().filter({ $0.date.getYear() == lastYear && $0.highHandBonus != nil }).map { $0.highHandBonus ?? 0 }.reduce(0,+)
            }
        case .tournaments:
            return 0
        }
    }
}
