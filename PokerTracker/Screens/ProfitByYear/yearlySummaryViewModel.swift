//
//  ProfitByYearViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/6/22.
//

import SwiftUI

class yearlySummaryViewModel: ObservableObject {
    
    @ObservedObject var vm = SessionsListViewModel()
    
    @Published var myNewTimeline: PickerTimeline = .ytd {
        didSet {
            loadingChart()
        }
    }
    
//    @Published var selectedTimeline: String = "YTD" {
//        didSet {
//            loadingChart()
//        }
//    }
    
    @Published var isLoading: Bool = false
    
    func loadingChart() {
        self.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    enum PickerTimeline: String, CaseIterable {
        case all = "ALL"
        case ytd = "YTD"
        case lastYear
        
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }
    
    // MARK: Functions for calculating metrics in Yearly Summary
    
    func netProfitCalc(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.tallyBankroll()
        case .ytd:
            return vm.bankrollByYear(year: Date().getYear())
        case .lastYear:
            return vm.bankrollByYear(year: Date().modifyDays(days: -360).getYear())
        }
    }
    
    func hourlyCalc(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.hourlyRate()
        case .ytd:
            return vm.hourlyByYear(year: Date().getYear())
        case .lastYear:
            return vm.hourlyByYear(year: Date().modifyDays(days: -360).getYear())
        }
    }
    
    func avgProfit(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.avgProfit()
        case .ytd:
            return vm.avgProfitByYear(year: Date().getYear())
        case .lastYear:
            return vm.avgProfitByYear(year: Date().modifyDays(days: -360).getYear())
        }
    }
    
    func expensesByYear(timeline: PickerTimeline) -> Int {
        switch timeline {
        case .all:
            return vm.totalExpenses()
        case .ytd:
            return vm.totalExpensesByYear(year: Date().getYear())
        case .lastYear:
            return vm.totalExpensesByYear(year: Date().modifyDays(days: -360).getYear())
        }
    }
    
    func totalHours(timeline: PickerTimeline) -> String {
        switch timeline {
        case .all:
            return vm.totalHoursPlayed()
        case .ytd:
            return vm.hoursPlayedByYear(year: Date().getYear())
        case .lastYear:
            return vm.hoursPlayedByYear(year: Date().modifyDays(days: -360).getYear())
        }
    }
    
    func chartData(timeline: PickerTimeline) -> [Point] {
        switch timeline {
        case .all:
            return vm.chartCoordinates()
        case .ytd:
            return vm.yearlyChartCoordinates(year: Date().getYear())
        case .lastYear:
            return vm.yearlyChartCoordinates(year: Date().modifyDays(days: -360).getYear())
        }
    }
}
