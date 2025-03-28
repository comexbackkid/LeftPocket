//
//  DayOfWeekChart.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/24.
//

import SwiftUI
import Charts

struct DayOfWeekChart: View {
    
    let sessions: [PokerSession_v2]
        
    var body: some View {
        
        let proportions = calculateProportions(sessions: sessions)
        
        ZStack {
            
            // Gray Bar
            Chart(proportions) { dayProfit in
                
                BarMark(
                    x: .value("Proportion", 1.0),
                    y: .value("Day", dayProfit.day),
                    height: 10.0
                )
                .foregroundStyle(Color(.systemGray6))
                .cornerRadius(15)
                .annotation(position: .leading) {
                    Text(dayProfit.day)
                        .font(.custom("Asap-Regular", size: 12))
                        .foregroundColor(.clear)
                        .frame(maxWidth: 37, alignment: .trailing)
                        .padding(.trailing, 10)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.clear)
                    .border(Color.clear, width: 0)
            }
            .chartXScale(domain: 0...1)
            .padding(.leading, 30)
            .padding()
            
            // Colored Bar
            Chart(proportions) { dayProfit in
                
                BarMark(
                    x: .value("Proportion", max(dayProfit.proportion, 0)),
                    y: .value("Day", dayProfit.day),
                    height: 10.0
                )
                .foregroundStyle(.linearGradient(colors: [.teal, .mint], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(15)
                .annotation(position: .leading) {
                    Text(dayProfit.day)
                        .font(.custom("Asap-Regular", size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: 37, alignment: .trailing)
                        .padding(.trailing, 10)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.clear)
                    .border(Color.clear, width: 0)
            }
            .chartXScale(domain: 0...1)
            .padding(.leading, 30)
            .padding()
        }
        .padding(.trailing, 5)
    }
}

func calculateProportions(sessions: [PokerSession_v2]) -> [DayOfWeekProfit] {
    let calendar = Calendar.current
    
    // Define custom abbreviations for each weekday
    let dayAbbreviations = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // Group sessions by the weekday and sum profits
    let groupedProfits = Dictionary(grouping: sessions) { session in
        calendar.component(.weekday, from: session.date)
    }.mapValues { sessions in
        sessions.map { Double($0.profit) }.reduce(0, +)
    }
    
    // Filter out negative profits and calculate total positive profit
    let positiveProfits = groupedProfits.filter { $0.value > 0 }
    let totalPositiveProfit = positiveProfits.values.reduce(0, +)

    // Ensure all days of the week are represented
    let allDays: [(Int, String)] = Array(1...7).map { weekday in
        (weekday, dayAbbreviations[weekday - 1])
    }

    // Create DayOfWeekProfit data
    return allDays.map { (weekday, dayName) in
        let profit = (groupedProfits[weekday] ?? 0)
        let validProfit = profit > 0 ? profit : 0 // Ignore negative profits
        
        let proportion = totalPositiveProfit > 0 ? validProfit / totalPositiveProfit : 0
        return DayOfWeekProfit(day: dayName, profit: validProfit, proportion: proportion)
    }
}

struct DayOfWeekProfit: Identifiable {
    let id = UUID()
    let day: String
    let profit: Double
    let proportion: Double
}

#Preview {
    DayOfWeekChart(sessions: MockData.allSessions)
        .frame(height: 280)
}
