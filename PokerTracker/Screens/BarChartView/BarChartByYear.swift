//
//  BarChartByYear.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/14/24.
//

import SwiftUI
import Charts

struct BarChartByYear: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @State private var selectedMonth: Date?
    
    let showTitle: Bool
    let moreAxisMarks: Bool
    let firstDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 1, day: 1)
    let lastDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 12, day: 31)
    
    var sessionProfitByMonth: [(month: Date, profit: Int)] {
        
        sessionsByMonth(sessions: viewModel.sessions)

    }
    var profitAnnotation: Int? {
        
        profitByMonth(month: selectedMonth ?? Date(), data: viewModel.sessions)
        
    }
    
    var body: some View {
        
        VStack {
            
            if showTitle {
                
                HStack {
                    Text("Monthly Totals")
                        .cardTitleStyle()
                    
                    Spacer()
                    
                }
                .padding(.bottom, 40)
            }
            
            if #available(iOS 17.0, *) {
                barChart
            } else {
                barChartOldVersion
            }
        }
    }
    
    @available(iOS 17, *)
    var barChart: some View {
        
        Chart {
            
            // The reason for the ForEach statement is because it's the only way to use the 'if let' statement getting
            // values from RuleMark and using it as an overlay
            ForEach(sessionProfitByMonth, id: \.month) { monthlyTotal in
                
                BarMark(x: .value("Month", monthlyTotal.month, unit: .month), y: .value("Profit", monthlyTotal.profit))
                    .cornerRadius(6)
                    .foregroundStyle(Color.pink.gradient)
                    .opacity(selectedMonth == nil || selectedMonth?.getMonth() == monthlyTotal.month.getMonth() ? 1 : 0.5)
            }
            
            if let selectedMonth {
                
                RuleMark(x: .value("Selected Date", selectedMonth, unit: .month))
                    .foregroundStyle(.gray.opacity(0.3))
                    .zIndex(-1)
                    .annotation(position: .top, spacing: 7, overflowResolution: .init(x: .fit(to: .chart))) {
                        Text(profitAnnotation ?? 0, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                            .captionStyle()
                            .padding(10)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                
            }
        }
        .sensoryFeedback(.selection, trigger: profitAnnotation)
        .chartXSelection(value: $selectedMonth)
        .chartXScale(domain: [firstDay, lastDay])
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: moreAxisMarks ? 4 : 3)) { value in
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.2))
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
    
    var barChartOldVersion: some View {
        
        Chart {
            
            // The reason for the ForEach statement is because it's the only way to use the 'if let' statement getting
            // values from RuleMark and using it as an overlay
            ForEach(sessionProfitByMonth, id: \.month) { monthlyTotal in
                
                BarMark(x: .value("Month", monthlyTotal.month, unit: .month), y: .value("Profit", monthlyTotal.profit))
                    .cornerRadius(6)
                    .foregroundStyle(Color.pink.gradient)
                    .opacity(selectedMonth == nil || selectedMonth?.getMonth() == monthlyTotal.month.getMonth() ? 1 : 0.5)
            }
        }
        .chartXScale(domain: [firstDay, lastDay])
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: moreAxisMarks ? 4 : 3)) { value in
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.2))
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
    
    // Formats data so we have the profit totals of every month, i.e. only 12 total items in the array. Checks current year only
    func sessionsByMonth(sessions: [PokerSession]) -> [(month: Date, profit: Int)] {
        
        var monthlyProfits: [Date: Int] = [:]
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Iterate through sessions and accumulate profit for each month
        for session in sessions {
            
            let yearOfSession = Calendar.current.component(.year, from: session.date)
            
            // Check if the session is from the current year
            if yearOfSession == currentYear {
                let month = Calendar.current.startOfMonth(for: session.date)
                monthlyProfits[month, default: 0] += session.profit
            }
        }
        
        // Convert the dictionary to an array of tuples
        let result = monthlyProfits.map { (month: $0.key, profit: $0.value) }
        
        return result
    }
    
    // For use in calculating annoations value
    func profitByMonth(month: Date, data: [PokerSession]) -> Int {
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let filteredSessions = data.filter({ $0.date.getMonth() == month.getMonth() && Int($0.date.getYear()) == currentYear })
        let formattedSessions = filteredSessions.map({ $0.profit }).reduce(0, +)
        return formattedSessions
    }
}

#Preview {
    BarChartByYear(showTitle: true, moreAxisMarks: true)
        .environmentObject(SessionsListViewModel())
        .frame(height: 350)
        .padding()
}
