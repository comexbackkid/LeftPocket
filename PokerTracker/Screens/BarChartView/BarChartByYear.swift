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
    
    let showTitle: Bool
    let moreAxisMarks: Bool
    let firstDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 1, day: 1)
    let lastDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 12, day: 31)
    let cashOnly: Bool
    
    var body: some View {
        
        VStack {
            
            if #available(iOS 17.0, *) {
                
                barChart
                
            } else {
                
                barChartOldVersion
            }
        }
    }
    
    @available(iOS 17, *)
    var barChart: some View {
        
        VStack {
            
            VStack (alignment: .leading, spacing: 3) {
                if showTitle {
                    
                    HStack {
                        Text("Monthly Totals")
                            .cardTitleStyle()
                        
                        Spacer()
                        
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
                        .foregroundStyle(monthlyTotal.profit > 0 ? Color.lightGreen.gradient : Color.donutChartRed.gradient)
                        .opacity(selectedMonth == nil || selectedMonth?.getMonth() == monthlyTotal.month.getMonth() ? 1 : 0.4)
                }
                
                if let selectedMonth {
                    
                    RuleMark(x: .value("Selected Date", selectedMonth, unit: .month))
                        .foregroundStyle(.gray.opacity(0.3))
                        .zIndex(-1)
                }
            }
            .sensoryFeedback(.selection, trigger: profitAnnotation)
            .chartXSelection(value: $selectedMonth.animation(.easeInOut.speed(2.0)))
            .chartXScale(domain: [firstDay, lastDay])
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: moreAxisMarks ? 4 : 3)) { value in
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
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2, 8]))
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel(format: .dateTime.month(.abbreviated),
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
    
    var barChartOldVersion: some View {
        
        Chart {
            
            // The reason for the ForEach statement is because it's the only way to use the 'if let' statement getting
            // values from RuleMark and using it as an overlay
            ForEach(sessionProfitByMonth, id: \.month) { monthlyTotal in
                
                BarMark(x: .value("Month", monthlyTotal.month, unit: .month), y: .value("Profit", monthlyTotal.profit))
                    .cornerRadius(3)
                    .foregroundStyle(monthlyTotal.profit > 0 ? Color.lightGreen.gradient : Color.pink.gradient)
                    .opacity(selectedMonth == nil || selectedMonth?.getMonth() == monthlyTotal.month.getMonth() ? 1 : 0.4)
            }
        }
        .chartXScale(domain: [firstDay, lastDay])
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: moreAxisMarks ? 4 : 3)) { value in
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
                AxisValueLabel(format: .dateTime.month(.abbreviated),
                               horizontalSpacing: sessionProfitByMonth.isEmpty ? 25 : 0,
                               verticalSpacing: 15).font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
            }
        }
        
    }
    
    var profitAnnotation: Int? {
        
        guard let selectedMonth = selectedMonth else {
            
            return nil
        }
        
        return profitByMonth(month: selectedMonth, data: viewModel.sessions)
    }
    
    var sessionProfitByMonth: [(month: Date, profit: Int)] {
        
        sessionsByMonth(sessions: viewModel.sessions, cashOnly: cashOnly)
    }
    
    // Formats data so we have the profit totals of every month, i.e. only 12 total items in the array. Checks current year only
    func sessionsByMonth(sessions: [PokerSession], cashOnly: Bool) -> [(month: Date, profit: Int)] {
        
        var monthlyProfits: [Date: Int] = [:]
        let currentYear = Calendar.current.component(.year, from: Date())
        
        if cashOnly == true {
            let cashSessions = sessions.filter({ $0.isTournament == false || $0.isTournament == nil })
            
            for session in cashSessions {
                
                let yearOfSession = Calendar.current.component(.year, from: session.date)
                
                // Check if the session is from the current year
                if yearOfSession == currentYear {
                    let month = Calendar.current.startOfMonth(for: session.date)
                    
                    monthlyProfits[month, default: 0] += session.profit
                }
            }
            
        } else {
            // Iterate through sessions and accumulate profit for each month
            for session in sessions {
                
                let yearOfSession = Calendar.current.component(.year, from: session.date)
                
                // Check if the session is from the current year
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
    func profitByMonth(month: Date, data: [PokerSession]) -> Int {
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let filteredSessions = data.filter({ $0.date.getMonth() == month.getMonth() && Int($0.date.getYear()) == currentYear })
        let formattedSessions = filteredSessions.map({ $0.profit }).reduce(0, +)
        return formattedSessions
    }
}

#Preview {
    BarChartByYear(showTitle: true, moreAxisMarks: true, cashOnly: false)
        .environmentObject(SessionsListViewModel())
        .frame(height: 350)
        .padding()
        .preferredColorScheme(.dark)
}
