//
//  ProfitByYearViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/6/22.
//

import SwiftUI

class AnnualReportViewModel: ObservableObject {
    
    @ObservedObject var vm = SessionsListViewModel()
    
    @Published var myNewTimeline: PickerTimeline = .ytd
    
    let lastYear = Date().modifyDays(days: -365).getYear()
    
    enum PickerTimeline: String, CaseIterable {
        case all = "ALL"
        case ytd = "YTD"
        case lastYear
        
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }
    
    // MARK: Functions for calculating metrics in Yearly Summary
    
    func chartRange(timeline: PickerTimeline) -> [PokerSession] {
        switch timeline {
        case .all:
            vm.sessions
        case .ytd:
            vm.allSessionDataByYear(year: Date().getYear())
        case .lastYear:
            vm.allSessionDataByYear(year: lastYear)
        }
    }
    
    func grossIncome(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.grossIncome()
        case .ytd:
            return vm.grossIncomeByYear(year: Date().getYear())
        case .lastYear:
            return vm.grossIncomeByYear(year: lastYear)
        }
    }
    
    func netProfitCalc(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.tallyBankroll(bankroll: .all)
        case .ytd:
            return vm.bankrollByYear(year: Date().getYear())
        case .lastYear:
            return vm.bankrollByYear(year: lastYear)
        }
    }
    
    func hourlyCalc(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.hourlyRate(bankroll: .all)
        case .ytd:
            return vm.hourlyByYear(year: Date().getYear())
        case .lastYear:
            return vm.hourlyByYear(year: lastYear)
        }
    }
    
    func avgProfit(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.avgProfit(bankroll: .all)
        case .ytd:
            return vm.avgProfitByYear(year: Date().getYear())
        case .lastYear:
            return vm.avgProfitByYear(year: lastYear)
        }
    }
    
    func winRate(timeline: PickerTimeline) -> String {
        switch timeline {
        case .all:
            return vm.winRate()
        case .ytd:
            return vm.winRateByYear(year: Date().getYear())
        case .lastYear:
            return vm.winRateByYear(year: lastYear)
        }
    }
    
    func expensesByYear(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.totalExpenses()
        case .ytd:
            return vm.totalExpensesByYear(year: Date().getYear())
        case .lastYear:
            return vm.totalExpensesByYear(year: lastYear)
        }
    }
    
    func totalHours(timeline: PickerTimeline) -> String {
        switch timeline {
        case .all:
            return vm.totalHoursPlayed(bankroll: .all)
        case .ytd:
            return vm.hoursPlayedByYear(year: Date().getYear())
        case .lastYear:
            return vm.hoursPlayedByYear(year: lastYear)
        }
    }
    
    func sessionsPerYear(timeline: PickerTimeline) -> String {
        switch timeline {
        case .all:
            return String(vm.sessions.count)
        case .ytd:
            return String(vm.sessionsPerYear(year: Date().getYear()))
        case .lastYear:
            return String(vm.sessionsPerYear(year: lastYear))
        }
    }
    
    func chartData(timeline: PickerTimeline) -> [Point] {
        switch timeline {
        case .all:
            return vm.chartCoordinates()
        case .ytd:
            return vm.yearlyChartCoordinates(year: Date().getYear())
        case .lastYear:
            return vm.yearlyChartCoordinates(year: lastYear)
        }
    }
    
    func bestLocation(timeline: PickerTimeline) -> LocationModel {
        switch timeline {
        case .all:
            return vm.bestLocation() ?? DefaultData.defaultLocation
        case .ytd:
            return vm.bestLocation(year: Date().getYear()) ?? DefaultData.defaultLocation
        case .lastYear:
            return vm.bestLocation(year: lastYear) ?? DefaultData.defaultLocation
        }
    }
    
    func bestProfit(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.bestSession() ?? 0
        case .ytd:
            return vm.bestSession(year: Date().getYear()) ?? 0
        case .lastYear:
            return vm.bestSession(year: lastYear) ?? 0
        }
    }
}
