//
//  BarChartDailyCount.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/1/25.
//

import SwiftUI
import Charts

struct BarChartDailyCount: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    let showTitle: Bool
    var dateRange: [PokerSession_v2]
    var hoursByDay: [(day: Int, totalHours: Double)] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: dateRange) { session in
            calendar.component(.day, from: session.date)
        }
        
        return grouped
            .map { day, sessionsOnDay in
                let total = sessionsOnDay.reduce(0.0) { sum, session in
                    let comps = calendar.dateComponents([.hour, .minute], from: session.startTime, to: session.endTime)
                    let hours = Double(comps.hour ?? 0) + Double(comps.minute ?? 0)/60
                    return sum + hours
                }
                
                return (day: day, totalHours: total)
            }
            .sorted { $0.day < $1.day }
    }
    var daysInMonth: Int {
        guard let firstDate = dateRange.first?.date, let range = Calendar.current.range(of: .day, in: .month, for: firstDate) else {
            return 31
        }
        
        return range.count
    }
    
    var body: some View {
        
        VStack {
            
            if showTitle {
                
                HStack {
                    Text("Daily Volume")
                        .cardTitleStyle()
                    Spacer()
                }
                .padding(.bottom, 16)
            }
            
            barChart
        }
    }
    
    @ViewBuilder
    private var barChart: some View {
        Chart {
            ForEach(hoursByDay, id: \.day) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Hours", data.totalHours),
                    width: 4
                )
                .cornerRadius(30)
                .foregroundStyle(.cyan.gradient)
            }
        }
        .chartXScale(domain: [1, daysInMonth])
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.33))
                AxisValueLabel {
                    if let intVal = value.as(Int.self) {
                        Text("\(intVal)h")
                            .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                            .padding(.trailing)
                    }
                }
            }
        }
    }
}

#Preview {
    let maySessions = SessionsListViewModel().allSessions.filter { Calendar.current.component(.month, from: $0.date) == 5 }
    BarChartDailyCount(showTitle: true, dateRange: maySessions)
        .frame(height: 200)
        .padding()
        .padding(20)
        .environmentObject(SessionsListViewModel())
}
