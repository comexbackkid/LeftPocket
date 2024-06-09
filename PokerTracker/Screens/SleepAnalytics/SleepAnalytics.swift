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
    
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingPermissionPrimingSheet = false
    @Binding var activeSheet: Sheet?
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var hkManager: HealthKitManager
        
    var body: some View {
        
        ZStack {
            ScrollView {
                
                VStack {
                    
                    title
                    
                    instructions
                    
                    VStack (spacing: 22) {
                        
                        if #available(iOS 17.0, *) {
                            sleepChart
                        }
                        
                        ToolTipView(image: "bed.double.fill",
                                    message: "So far this year, you've played \(countLowSleepSessions()) session\(countLowSleepSessions() > 1 || countLowSleepSessions() < 1  ? "s" : "") under-rested.",
                                    color: .donutChartOrange)
                        
                        ToolTipView(image: "gauge",
                                    message: performanceComparison(),
                                    color: .chartAccent)
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("")
                    .padding(.bottom, 50)
                    .padding(.top)
                    .onAppear {
                        isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
                    }
                    .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                        Task {
                            await handleAuthorizationChecksAndDataFetch()
                        }
                    }, content: {
                        HealthKitPrimingView(hasSeen: $hasSeenPermissionPriming)
                    })
                }
                .task {
                    await hkManager.checkAuthorizationStatus()
                    if hkManager.authorizationStatus == .sharingAuthorized {
                        await hkManager.fetchSleepData()
                    }
                }
            }
            .background(Color.brandBackground)
            
            if activeSheet == .sleepAnalytics { dismissButton }
        }
    }
    
    private func handleAuthorizationChecksAndDataFetch() async {
        await hkManager.checkAuthorizationStatus()
        if hkManager.authorizationStatus == .sharingAuthorized {
            await hkManager.fetchSleepData()
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("Sleep Analytics")
                .titleStyle()
                
            
            Text("(Beta)")
                .headlineStyle()
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, activeSheet == .sleepAnalytics ? 0 : -37)
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Gain a deeper understanding of how sleep affects your game. Green bars represent profitable sessions, & red bars are days you lost money.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var footerText: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("The recommended sleep for adults older than 18 years is at least seven hours per night.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
        
    }
    
    var dismissButton: some View {
        
        VStack {
            
            HStack {
                
                Spacer()
                
                DismissButton()
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    .onTapGesture {
                        dismiss()
                    }
            }
            
            Spacer()
        }
    }
    
    @available(iOS 17.0, *)
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
                ForEach(hkManager.sleepData) { sleep in
                    BarMark(x: .value("Date", sleep.date), y: .value("Hours", sleep.value))
                        .foregroundStyle(calculateBarColor(healthMetric: sleep, viewModel: viewModel).gradient)
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned) {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel {
                        if let value = value.as(Double.self), value != 0 {
                            Text("\(value, specifier: "%.0f")h")
                                .padding(.leading, 18)
                        }
                    }
                }
            }
            .padding(.leading, 6)
        }
        .overlay {
            switch hkManager.authorizationStatus {
            case .notDetermined:
                ProgressView("Loading")
            case .sharingDenied:
                Text("HealthKit permission denied.")
            case .sharingAuthorized:
                EmptyView()
            @unknown default:
                ProgressView("Loading")
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 290)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
    }
    
    // Dynamically return red vs. green if the user won or lost money
    func calculateBarColor(healthMetric: SleepMetric, viewModel: SessionsListViewModel) -> Color {
        
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
            return Color.secondary.opacity(0.2)
        }
    }
    
    // Calculates how many sessions were played with less than 6 hours sleep since the start of the year
    func countLowSleepSessions() -> Int {
        
        // These are ALL sessions where you've slept under 6 hours. Later we filter for only this year
        let sessions = viewModel.sessions.filter {
            guard let sleep = hkManager.sleepData.sleepHours(on: $0.date) else { return false }
            return sleep < 6
        }
        
        return sessions.filter({ $0.date.getYear() == Date().getYear() }).count
    }
    
    // Calculates your hourly rate when you get at least 6 hours of sleep
    func performanceComparison() -> String {
        let sleepDataByDate = Dictionary(hkManager.sleepData.map { metric in
            (Calendar.current.startOfDay(for: metric.date), metric.value)
        }, uniquingKeysWith: { first, _ in first })  // Assume no duplicate dates for simplicity

        var hourlyRateWithEnoughSleep = 0.0
        var countWithEnoughSleep = 0
        var hourlyRateWithLessSleep = 0.0
        var countWithLessSleep = 0

        for session in viewModel.sessions {
                let sessionDate = Calendar.current.startOfDay(for: session.date)
                if let sleepHours = sleepDataByDate[sessionDate] {
                    if sleepHours >= 6 {
                        hourlyRateWithEnoughSleep += Double(session.hourlyRate)
                        countWithEnoughSleep += 1
                    } else {
                        hourlyRateWithLessSleep += Double(session.hourlyRate)
                        countWithLessSleep += 1
                    }
                }
            }

            if countWithEnoughSleep == 0 {
                if countWithLessSleep == 0 {
                    return "No data available to compare performances."
                }
                return "All sessions played with under 6 hours of sleep. No baseline available."
            }

            let avgHourlyRateWithEnoughSleep = hourlyRateWithEnoughSleep / Double(countWithEnoughSleep)
            let avgHourlyRateWithLessSleep = countWithLessSleep > 0 ? hourlyRateWithLessSleep / Double(countWithLessSleep) : 0

            // Calculate percentage improvement
            if avgHourlyRateWithLessSleep != 0 {
                let improvement = ((avgHourlyRateWithEnoughSleep - avgHourlyRateWithLessSleep) / abs(avgHourlyRateWithLessSleep)) * 100
                return "Your hourly rate is \(improvement.formatted(.number.precision(.fractionLength(0))))% \(improvement > 0 ? "greater" : "less") on days you sleep at least 6 hours."
            } else {
                return "No sessions logged with less than 6 hours of sleep. No baseline comparison available."
            }
    }
    
    func avgSleep() -> String {
        guard !hkManager.sleepData.isEmpty else { return "0" }
        let totalSleep = hkManager.sleepData.reduce(0) { $0 + $1.value }
        let avgSleep = Double(totalSleep) / Double(hkManager.sleepData.count)
        return avgSleep.formatted(.number.precision(.fractionLength(1)))
    }
}

#Preview {
    SleepAnalytics(activeSheet: .constant(.sleepAnalytics))
        .environmentObject(SessionsListViewModel())
        .environmentObject(HealthKitManager())
        .preferredColorScheme(.dark)
}
