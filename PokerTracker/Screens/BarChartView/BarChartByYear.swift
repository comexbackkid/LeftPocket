//
//  BarChartByYear.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/14/24.
//

import SwiftUI
import Charts

struct BarChartByYear: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    @State private var selectedMonth: Date?
    @AppStorage("sessionFilter") private var chartSessionFilter: SessionFilter = .all
    @State private var bankrollFilter: BankrollSelection = .default
    
    let showTitle: Bool
    let moreAxisMarks: Bool
    let firstDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 1, day: 1)
    let lastDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 12, day: 31)
    
    var body: some View {
        
        VStack {
            
            barChart
        }
    }
    
    var barChart: some View {
        
        VStack {
            
            VStack (alignment: .leading, spacing: 3) {
                if showTitle {
                    
                    HStack {
                        
                        Text("Monthly Totals")
                            .cardTitleStyle()
                        
                        Spacer()
                        
                        filterButton
                    }
                    
                    let amount = profitAnnotation
                    let month = Text(selectedMonth?.getMonth() ?? "No Selection")

                    Group {
                        if let amount {
                            HStack (spacing: 5) {
                                
                                if amount != 0 {
                                    Image(systemName: "arrow.up.right")
                                        .profitColor(total: amount)
                                        .rotationEffect(.degrees(amount < 0 ? 90 : 0))
                                        .animation(.default.speed(2), value: amount)
                                }
                                
                                Text("\(amount.formatted(.currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))))")
                                    .font(.custom("Asap-Medium", size: 17))
                                    .profitColor(total: amount)
                                
                                Text("in \(month)")
                                    .font(.custom("Asap-Medium", size: 17))
                                    .foregroundStyle(.secondary)
                            }
                            
                        } else {
                            Text("\(month)")  // Show only the month if amount is nil
                                .font(.custom("Asap-Medium", size: 17))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .animation(nil, value: selectedMonth)
                }
            }
            .padding(.bottom, 30)
            
            Chart {
                ForEach(sessionProfitByMonth, id: \.month) { monthlyTotal in
                    
                    BarMark(x: .value("Month", monthlyTotal.month, unit: .month), y: .value("Profit", monthlyTotal.profit))
                        .cornerRadius(3)
                        .foregroundStyle(monthlyTotal.profit > 0 ? Color.lightGreen.gradient : Color.pink.gradient)
                        .opacity(selectedMonth == nil || selectedMonth?.getMonth() == monthlyTotal.month.getMonth() ? 1 : 0.4)
                }
                
                if let selectedMonth {
                    RuleMark(x: .value("Selected Date", selectedMonth, unit: .month))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6]))
                        .foregroundStyle(.gray.opacity(0.33))
                        .zIndex(-1)
                }
            }
            .sensoryFeedback(.selection, trigger: profitAnnotation)
            .chartXSelection(value: $selectedMonth.animation(.easeInOut.speed(2.0)))
            .chartXScale(domain: [firstDay, lastDay])
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: moreAxisMarks ? 5 : 3)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.axisShortHand(viewModel.userCurrency))
                                .captionStyle()
                                .padding(.trailing, 15)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks {
//                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2, 8]))
//                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits),
                                   horizontalSpacing: sessionProfitByMonth.isEmpty ? 25 : 0,
                                   verticalSpacing: 15).font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                }
            }
            .overlay {
                if sessionProfitByMonth.isEmpty {
                    VStack {
                        Text("No chart data to display.")
                            .calloutStyle()
                            .foregroundStyle(.secondary)
                    }
                    .offset(y: -20)
                }
            }
        }
    }
    
    var filterButton: some View {
        
        Menu {
            
            Menu {
                Picker("Bankroll Picker", selection: $bankrollFilter) {
                    Text("All").tag(BankrollSelection.all)
                    Text("Default").tag(BankrollSelection.default)
                    ForEach(viewModel.bankrolls) { bankroll in
                        Text(bankroll.name).tag(BankrollSelection.custom(bankroll.id))
                    }
                }
                
            } label: {
                HStack {
                    Text("Bankrolls")
                    Image(systemName: "bag.fill")
                }
            }
            
            Picker("Session Filter", selection: $chartSessionFilter) {
                ForEach(SessionFilter.allCases, id: \.self) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            
        } label: {
            Text(chartSessionFilter.rawValue.capitalized + " ›")
                .bodyStyle()
        }
        .tint(.brandPrimary)
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    var allSessions: [PokerSession_v2] {
        switch bankrollFilter {
        case .all: return viewModel.sessions + viewModel.bankrolls.flatMap(\.sessions)
        case .default: return viewModel.sessions
        case .custom(let id): return viewModel.bankrolls.first(where: { $0.id == id })?.sessions ?? []
        }
    }
  
    var profitAnnotation: Int? {
        guard let selectedMonth else { return nil }
        return profitByMonth(month: selectedMonth, data: allSessions, sessionFilter: chartSessionFilter)
    }
    
    var sessionProfitByMonth: [(month: Date, profit: Int)] {
        sessionsByMonth(sessions: allSessions, sessionFilter: chartSessionFilter)
    }
    
    // Formats data so we have the profit totals of every month, i.e. only 12 total items in the array. Checks current year only
    func sessionsByMonth(sessions: [PokerSession_v2], sessionFilter: SessionFilter, year: Date? = nil) -> [(month: Date, profit: Int)] {
        
        var monthlyProfits: [Date: Int] = [:]
        let currentYear = Calendar.current.component(.year, from: year ?? Date())
        
        switch sessionFilter {
        case .all:
            for session in sessions {
                let yearOfSession = Calendar.current.component(.year, from: session.date)

                if yearOfSession == currentYear {
                    let month = Calendar.current.startOfMonth(for: session.date)
                    monthlyProfits[month, default: 0] += session.profit
                }
            }
        case .cash:
            let cashSessions = sessions.filter({ $0.isTournament == false })
            
            for session in cashSessions {
                let yearOfSession = Calendar.current.component(.year, from: session.date)
                
                if yearOfSession == currentYear {
                    let month = Calendar.current.startOfMonth(for: session.date)
                    monthlyProfits[month, default: 0] += session.profit
                }
            }
        case .tournaments:
            let tournamentSessions = sessions.filter({ $0.isTournament == true })
            
            for session in tournamentSessions {
                let yearOfSession = Calendar.current.component(.year, from: session.date)
                
                if yearOfSession == currentYear {
                    let month = Calendar.current.startOfMonth(for: session.date)
                    monthlyProfits[month, default: 0] += session.profit
                }
            }
        }
        
        // Convert the dictionary to an array of tuples
        let result = monthlyProfits.map { (month: $0.key, profit: $0.value) }
        
        return result
    }
    
    // Calculates annoations value
    func profitByMonth(month: Date, data: [PokerSession_v2], sessionFilter: SessionFilter) -> Int {
        
        let currentYear = Calendar.current.component(.year, from: Date())
        var filteredSessions: [PokerSession_v2] = []
        
        switch sessionFilter {
        case .all:
            filteredSessions = data.filter({ $0.date.getMonth() == month.getMonth() && Int($0.date.getYear()) == currentYear })
        case .cash:
            let cashSessions = data.filter({ $0.isTournament == false })
            filteredSessions = cashSessions.filter({ $0.date.getMonth() == month.getMonth() && Int($0.date.getYear()) == currentYear })
        case .tournaments:
            let tournamentSessions = data.filter({ $0.isTournament == true })
            filteredSessions = tournamentSessions.filter({ $0.date.getMonth() == month.getMonth() && Int($0.date.getYear()) == currentYear })
        }

        let formattedSessions = filteredSessions.map({ $0.profit }).reduce(0, +)
        return formattedSessions
    }
}

#Preview {
    BarChartByYear(showTitle: true, moreAxisMarks: true)
        .environmentObject(SessionsListViewModel())
        .frame(height: 350)
        .padding()
        .preferredColorScheme(.dark)
}
