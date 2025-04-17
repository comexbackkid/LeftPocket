//
//  BarChartByWeekDay.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/15/25.
//

import SwiftUI
import Charts

struct BarChartByWeekDay: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    let showTitle: Bool
    var dateRange: [PokerSession_v2]
    
    // Helper to abbreviate a weekday.
    private func abbreviate(weekday full: String) -> String {
        let calendar = Calendar.current
        if let index = calendar.weekdaySymbols.firstIndex(of: full) {
            return calendar.shortWeekdaySymbols[index]
        }
        return full
    }
    
    var hoursByDay: [(day: String, totalHours: Double)] {
        let calendar = Calendar.current
        let weekdayOrder = calendar.weekdaySymbols  // ["Sunday", "Monday", "Tuesday", ...]
        
        // Group sessions by weekday using the getWeekday() extension on Date
        let grouped = Dictionary(grouping: dateRange) { session in
            session.date.getWeekday()
        }
        
        // Compute total hours per day for only those days that have sessions.
        let hoursPerDay: [String: Double] = grouped.mapValues { sessions in
            sessions.reduce(0.0) { total, session in
                let duration = Calendar.current.dateComponents([.hour, .minute], from: session.startTime, to: session.endTime)
                let hours = Double(duration.hour ?? 0) + Double(duration.minute ?? 0) / 60.0
                return total + hours
            }
        }
        
        // Create an array for every day in the fixed weekday order.
        // If there's no data for a day, default its total hours to 0.
        let result = weekdayOrder.map { day in
            (day: day, totalHours: hoursPerDay[day] ?? 0)
        }
        
        return result
    }
    
    var body: some View {
        
        VStack {
            
            if showTitle {
                
                HStack {
                    Text("Hours Played by Day")
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
                ForEach(hoursByDay, id: \.day) { dayData in
                    BarMark(
                        x: .value("Day", abbreviate(weekday: dayData.day)),
                        y: .value("Hours", dayData.totalHours),
                        width: 12
                    )
                    .cornerRadius(4)
                    .foregroundStyle(.blue.gradient)
                }
            }
            .animation(.bouncy.speed(1.0), value: dateRange)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel() {
                        if let day = value.as(String.self) {
                            Text(day)
                                .font(.custom("AsapCondensed-Bold", size: 12, relativeTo: .caption2))
                                .padding(.top, 10)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine().foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(Int(doubleValue))h")
                                .font(.custom("AsapCondensed-Bold", size: 12, relativeTo: .caption2))
                                .padding(.trailing, 15)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    BarChartByWeekDay(showTitle: true, dateRange: SessionsListViewModel().sessions)
        .frame(height: 200)
        .padding()
        .padding(20)
        .environmentObject(SessionsListViewModel())
}
