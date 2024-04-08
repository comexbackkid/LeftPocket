//
//  BarChartByStakes.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/8/24.
//

import SwiftUI
import Charts

struct BarChartByStakes: View {
    @EnvironmentObject var viewModel: SessionsListViewModel
    @State private var selectedMonth: Date?
    
    let showTitle: Bool
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
            }
        }
    }
    
    @available(iOS 17, *)
    var barChart: some View {
        
        Chart {
            ForEach(viewModel.sessions, id: \.self) { session in
                
                BarMark(x: .value("Month", session.date, unit: .month), y: .value("Profit", session.profit))
                    .cornerRadius(20)
                    .foregroundStyle(by: .value("Stakes", session.stakes))
                    
            }
        }
        .chartForegroundStyleScale(range: [.orange, .pink, .yellow])
        .chartLegend(position: .automatic, alignment: .center, spacing: 15)
        .sensoryFeedback(.selection, trigger: profitAnnotation)
        .chartXSelection(value: $selectedMonth)
        .chartXScale(domain: [firstDay, lastDay])
        .chartYAxis {
            AxisMarks(position: .leading) { value in
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
    BarChartByStakes(showTitle: true)
        .frame(height: 400)
        .padding()
        .environmentObject(SessionsListViewModel())
}
