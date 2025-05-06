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
    var dateRange: [PokerSession_v2]
    var hoursByWeek: [(weekOfYear: Int, totalHours: Double)] {
        let calendar = Calendar.current
        
        // Group sessions by week of the year
        let grouped = Dictionary(grouping: dateRange) { session -> Int in
            return calendar.component(.weekOfYear, from: session.date)
        }
        
        // Sum hours played in each group
        let hoursByWeek = grouped.map { weekOfYear, sessionsInWeek -> (Int, Double) in
            let totalHours = sessionsInWeek.reduce(0.0) { total, session in
                // Calculate the session duration in hours
                let duration = Calendar.current.dateComponents([.hour, .minute], from: session.startTime, to: session.endTime)
                let hours = Double(duration.hour ?? 0) + Double(duration.minute ?? 0) / 60.0
                return total + hours
            }
            return (weekOfYear, totalHours)
        }
        .sorted { $0.0 < $1.0 }
        
        return hoursByWeek
    }
    
    var body: some View {
        
        VStack {
            
            if showTitle {
                HStack {
                    Text("Weekly Volume")
                        .cardTitleStyle()
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            
            barChart
        }
    }
    
    var barChart: some View {
        
        VStack {
            Chart {
                ForEach(hoursByWeek, id: \.weekOfYear) { weekData in
                    BarMark(x: .value("Week", weekData.weekOfYear), y: .value("Hours", weekData.totalHours), width: 4)
                        .cornerRadius(30)
                        .foregroundStyle(.cyan.gradient)
                }
            }
            .chartXScale(domain: [1, 52])
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)h")
                                .font(.custom("AsapCondensed-Bold", size: 12, relativeTo: .caption2))
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
            
            HStack {
                Text("Jan")
                    .font(.custom("AsapCondensed-Bold", size: 12, relativeTo: .caption2))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("Dec")
                    .font(.custom("AsapCondensed-Bold", size: 12, relativeTo: .caption2))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 26)
            .padding(.top, 10)
        }
    }
}

#Preview {
    BarChartWeeklySessionCount(showTitle: true, dateRange: SessionsListViewModel().sessions)
        .frame(height: 200)
        .padding()
        .padding(20)
        .environmentObject(SessionsListViewModel())
}
