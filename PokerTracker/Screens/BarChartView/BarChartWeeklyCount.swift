//
//  BarChartWeeklyCount.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/8/24.
//

import SwiftUI
import Charts

struct BarChartWeeklySessionCount: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    let showTitle: Bool
    var dateRange: [PokerSession]

    // Prepare sessions by week for the chart
    var sessionsByWeek: [(weekOfYear: Int, sessionCount: Int)] {
        let calendar = Calendar.current
        
        // Group sessions by week of the year
        let grouped = Dictionary(grouping: dateRange) { session -> Int in
            return calendar.component(.weekOfYear, from: session.date)
        }
        
        // Count sessions in each group
        let sessionsCountByWeek = grouped.map { weekOfYear, sessionsInWeek -> (Int, Int) in
            (weekOfYear, sessionsInWeek.count)
        }
        .sorted { $0.0 < $1.0 }
        
        return sessionsCountByWeek
    }
    
    var body: some View {
        
        VStack {
            
            if showTitle {
                HStack {
                    Text("Weekly Session Count")
                        .cardTitleStyle()
                    
                    Spacer()
                    
                }
                .padding(.bottom, 40)
            }
            
            barChart

        }
    }
    
    var barChart: some View {
        
        Chart {
            
            ForEach(sessionsByWeek, id: \.weekOfYear) { weekData in
                
                BarMark(x: .value("Week", weekData.weekOfYear), y: .value("Count", weekData.sessionCount), width: 3)
                    .cornerRadius(30)
                    .foregroundStyle(.cyan.gradient)
            }
        }
        .chartXScale(domain: [1, 52])
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.2))
                AxisValueLabel() {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .captionStyle()
                            .padding(.trailing, 10)
                    }
                }
            }
        }
//        .overlay(alignment: .bottomLeading) {
//                // Starting label
//                Text("Jan 1")
//                .captionStyle()
//                .opacity(0.5)
//                .offset(x: 5, y: 35)
//            }
//            .overlay(alignment: .bottomTrailing) {
//                // Ending label
//                Text("Dec 31")
//                    .captionStyle()
//                    .opacity(0.5)
//                    .offset(x: -5, y: 35)
//            }
    }
}

#Preview {
    BarChartWeeklySessionCount(showTitle: true, dateRange: SessionsListViewModel().sessions)
        .frame(height: 200)
        .padding()
        .padding(30)
        .environmentObject(SessionsListViewModel())
}
