//
//  SleepAnalytics.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/9/24.
//

import SwiftUI
import HealthKit
import Charts

struct SleepAnalytics: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                title
                
                instructions
                
                VStack (spacing: 22) {
                    
                    sleepChart
                    
                    ToolTipView(image: "bed.double.fill", 
                                message: "In the last 28 days, you've played \(countLowSleepSessions()) session\(countLowSleepSessions() > 1 ? "s" : "") under-rested.",
                                color: .donutChartOrange)
                    
                    ToolTipView(image: "gauge", 
                                message: "Your hourly rate is \(performanceComparison().formatted(.number.precision(.fractionLength(0))))% greater on days you sleep at least 7 hours.",
                                color: .chartAccent)
                }
                .padding(.top)
            }
        }
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Sleep Analytics")
                .titleStyle()
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, -37)
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Use this screen to gain a deeper understanding of how sleep affects your game. Green bars represent profitable sessions, & red bars are days you lost money.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var sleepChart: some View {
        
        VStack {
            VStack (alignment: .leading, spacing: 3) {
                HStack {
                    Text("Daily Sleep Totals")
                        .cardTitleStyle()
                    
                    Spacer()
                }
                
                Text("Avg " + avgSleep() + " hrs")
                    .subHeadlineStyle()
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 40)
            
            Chart {
                ForEach(HealthMetric.MockData) { sleep in
                    BarMark(x: .value("Date", sleep.date), y: .value("Hours", sleep.value))
                        .foregroundStyle(calculateBarColor(healthMetric: sleep, viewModel: viewModel).gradient)
                    
                }
            }
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation (.compactName)), horizontalSpacing: 20)
                }
            }
            .padding(.leading, 6)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 300)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
    }
    
    // Dynamically return red vs. green if the user won or lost money
    func calculateBarColor(healthMetric: HealthMetric, viewModel: SessionsListViewModel) -> Color {
        
        // Filter sessions to find any that match the date of the health metric
        let date = Calendar.current.startOfDay(for: healthMetric.date)
        let daysSessions = viewModel.sessions.filter { session in
            Calendar.current.isDate(session.date, inSameDayAs: date)
        }
        
        // Calculate total profit for the day
        let totalProfit = daysSessions.reduce(0) { (result, session) in
            result + session.profit
        }
        
        // Determine color based on profit
        if totalProfit > 0 {
            return Color.green
        } else if totalProfit < 0 {
            return Color.red
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
    
    // Calculates how many sessions were played with less than 7 hours sleep
    func countLowSleepSessions() -> Int {
        let sessions = viewModel.sessions.filter {
            guard let sleep = HealthMetric.MockData.sleepHours(on: $0.date) else { return false }
            return sleep < 7
        }
        
        return sessions.count
    }
    
    // Calculates how much more we've earned when we get good sleep
    func performanceComparison() -> Double {
        let sleepDataByDate = Dictionary(HealthMetric.MockData.map { metric in
            (Calendar.current.startOfDay(for: metric.date), metric.value)
        }, uniquingKeysWith: { first, _ in first })  // Assume no duplicate dates for simplicity

        var hourlyRateWithEnoughSleep = 0.0
        var countWithEnoughSleep = 0
        var hourlyRateWithLessSleep = 0.0
        var countWithLessSleep = 0

        for session in viewModel.sessions {
            let sessionDate = Calendar.current.startOfDay(for: session.date)
            if let sleepHours = sleepDataByDate[sessionDate] {
                if sleepHours >= 7 {
                    hourlyRateWithEnoughSleep += Double(session.hourlyRate)
                    countWithEnoughSleep += 1
                } else {
                    hourlyRateWithLessSleep += Double(session.hourlyRate)
                    countWithLessSleep += 1
                }
            }
        }

        let avgHourlyRateWithEnoughSleep = countWithEnoughSleep > 0 ? hourlyRateWithEnoughSleep / Double(countWithEnoughSleep) : 0
        let avgHourlyRateWithLessSleep = countWithLessSleep > 0 ? hourlyRateWithLessSleep / Double(countWithLessSleep) : 0

        // Calculate percentage improvement
        if avgHourlyRateWithLessSleep != 0 {
            let improvement = ((avgHourlyRateWithEnoughSleep - avgHourlyRateWithLessSleep) / abs(avgHourlyRateWithLessSleep)) * 100
            return improvement
        } else {
            return avgHourlyRateWithEnoughSleep > 0 ? Double.infinity : 0 // Handle division by zero if no sessions on low sleep days
        }
    }
    
    func avgSleep() -> String {
        guard !HealthMetric.MockData.isEmpty else { return "0" }
        let totalSleep = HealthMetric.MockData.reduce(0) { $0 + $1.value }
        let avgSleep = Double(totalSleep) / Double(HealthMetric.MockData.count)
        return avgSleep.formatted(.number.precision(.fractionLength(1)))
    }
}

#Preview {
    SleepAnalytics()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
    
}
