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
    @AppStorage("chartBankrollFilter") private var bankrollFilter: BankrollSelection = .default
    
    let showTitle: Bool
    let moreAxisMarks: Bool
    let firstDay: Date
    let lastDay: Date
    
    init(showTitle: Bool = true, moreAxisMarks: Bool = false, firstDay: Date? = nil, lastDay: Date? = nil) {
        self.showTitle = showTitle
        self.moreAxisMarks = moreAxisMarks
        
        // compute defaults for the current calendar year
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let defaultStart = Date.from(year: year, month: 1, day: 1)
        let defaultEnd   = Date.from(year: year, month: 12, day: 31)

        self.firstDay = firstDay ?? defaultStart
        self.lastDay  = lastDay  ?? defaultEnd
    }
    
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
                            Text("\(month)")
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
                    
                    BarMark(x: .value("Month", monthlyTotal.month, unit: .month), y: .value("Profit", monthlyTotal.profit), width: .fixed(14))
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
            .chartXScale(domain: firstDay...lastDay)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: moreAxisMarks ? 5 : 3)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.axisShortHand(viewModel.userCurrency))
                                .font(.custom("AsapCondensed-Light", size: 12, relativeTo: .caption2))
                                .padding(.trailing, 20)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits),
                                   horizontalSpacing: sessionProfitByMonth.isEmpty ? 25 : 0,
                                   verticalSpacing: 15).font(.custom("AsapCondensed-Light", size: 12, relativeTo: .caption2))
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
//            .background(
//                Circle()
//                    .fill(Color.lightGreen)
//                    .frame(width: 150, height: 150)
//                    .blur(radius: 80, opaque: false)
//                    .opacity(0.3)
//            )
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
        sessionsByMonth(sessions: allSessions, sessionFilter: chartSessionFilter, startDate: firstDay, endDate: lastDay)                   
    }
    
    // Formats data so we have the profit totals of every month, i.e. only 12 total items in the array. Checks current year only
    func sessionsByMonth(sessions: [PokerSession_v2], sessionFilter: SessionFilter, startDate: Date, endDate: Date) -> [(month: Date, profit: Int)] {
      
      let calendar = Calendar.current
      // build every month boundary in [startDate…endDate]
      var months: [Date] = []
      var cursor = calendar.startOfMonth(for: startDate)
      let lastMonth = calendar.startOfMonth(for: endDate)
        
        while cursor <= lastMonth {
            months.append(cursor)
            cursor = calendar.date(byAdding: .month, value: 1, to: cursor)!
        }
      
        // bucket profits
        var bucket: [Date: Int] = months.reduce(into: [:]) { $0[$1] = 0 }
        for session in sessions {
            
            guard session.date >= startDate, session.date <= endDate else { continue }
            switch sessionFilter {
            case .cash
                where session.isTournament: continue
            case .tournaments
                where !session.isTournament: continue
            default: break
            }
            
            let monthStart = calendar.startOfMonth(for: session.date)
            bucket[monthStart, default: 0] += session.profit
        }
      
        // map back into an array in chronological order
        return months.map { ($0, bucket[$0]!) }
    }
    
    // Calculates annoations value
    func profitByMonth(month: Date, data: [PokerSession_v2], sessionFilter: SessionFilter) -> Int {
        
        let calendar = Calendar.current
        let monthComponent = calendar.component(.month, from: month)
        let yearComponent  = calendar.component(.year,  from: month)
        
        let filtered = data.filter { session in
            let month = calendar.component(.month, from: session.date)
            let year = calendar.component(.year,  from: session.date)
            
            guard month == monthComponent, year == yearComponent else { return false }
            
            switch sessionFilter {
            case .all: return true
            case .cash: return !session.isTournament
            case .tournaments: return session.isTournament
            }
        }
        
        return filtered.map(\.profit).reduce(0, +)
    }
}

#Preview {
    BarChartByYear(showTitle: true, moreAxisMarks: true)
        .environmentObject(SessionsListViewModel())
        .frame(height: 350)
        .padding()
        .preferredColorScheme(.dark)
}
