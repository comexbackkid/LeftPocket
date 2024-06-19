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
    @State private var showError = false
    @State private var howThisWorksPopup = false
    @State private var rawSelectedDate: Date?
    @Binding var activeSheet: Sheet?
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var hkManager: HealthKitManager
    
    var selectedSleepMetric: SleepMetric? {
        guard let rawSelectedDate else { return nil }
        return hkManager.sleepData.first{
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var pokerSessionMatch: PokerSession? {
        guard let rawSelectedDate else { return nil }
        return viewModel.sessions.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
        
    var body: some View {
        
        ZStack {
            ScrollView {
                
                VStack {
                    
                    title
                    
                    instructions
                    
                    VStack (spacing: 22) {
                        
                        if #available(iOS 17.0, *) {
                            sleepChart
                        } else { oldSleepChart }
                        
                        selectedSessionStats
                        
                        ToolTipView(image: "bed.double.fill",
                                    message: "So far this year, you've played \(countLowSleepSessions()) session\(countLowSleepSessions() > 1 || countLowSleepSessions() < 1  ? "s" : "") under-rested.",
                                    color: .donutChartOrange)
                        
                        ToolTipView(image: "gauge",
                                    message: performanceComparison(),
                                    color: .chartAccent)
                        
                        sleepImportance
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("")
                    .padding(.bottom, 50)
                    .padding(.top)
                    .onAppear {
                        isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
                    }
                    .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                        Task { await handleAuthorizationChecksAndDataFetch() }
                    }, content: {
                        HealthKitPrimingView(hasSeen: $hasSeenPermissionPriming)
                    })
                }
            }
            .background(Color.brandBackground)
            
            if activeSheet == .sleepAnalytics { dismissButton }
        }
        .task { await handleAuthorizationChecksAndDataFetch() }
        .onChange(of: hkManager.errorMsg, perform: { _ in
            showError = true
        })
        .alert(isPresented: $showError) {
            Alert(title: Text("Uh oh!"), 
                  message: Text(hkManager.errorMsg ?? "An unknown error occurred."),
                  dismissButton: .default(Text("Ok")))
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
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                Text("Gain a deeper understanding of how sleep affects your game. Green bars represent winning sessions, red bars are days you lost money over the last month.")
                    .bodyStyle()
                
                Spacer()
            }
            
            HStack {
                
                Button {
                    howThisWorksPopup = true
                } label: {
                    HStack (spacing: 4) {
                        
                        Text("How is this calculated?")
                            .calloutStyle()
                        
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(Color.brandPrimary)
            }
            .popover(isPresented: $howThisWorksPopup, arrowEdge: .bottom, content: {
                PopoverView(bodyText: "Left Pocket gathers sleep numbers recorded from your smart device. If no sleep data is available, it defaults to using the estimated \"In Bed\" times generated by Apple's Health App.")
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    .frame(height: 180)
                    .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                    .presentationCompactAdaptation(.popover)
                    .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                    .shadow(radius: 10)
            })
        }
        .padding(.horizontal)
    }
    
    var selectedSessionStats: some View {
        
        VStack {
            
            HStack {
                Text("Selected Session Info")
                    .cardTitleStyle()
                    .padding(.bottom)
                
                Spacer()
            }
            
            HStack {
                
                VStack (spacing: 2) {
                    Text(selectedSleepMetric?.dayNoYear ?? "None")
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
                    
                    Text("Date")
                        .foregroundStyle(.secondary)
                        .font(.custom("Asap-Regular", size: 14, relativeTo: .callout))
                }
                .frame(width: 90)
                
                Divider()
                
                VStack (spacing: 2) {
                    Text("\(selectedSleepMetric?.value ?? 0, format: .number.rounded(increment: 0.1)) hrs")
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
                    
                    Text("Sleep")
                        .foregroundStyle(.secondary)
                        .font(.custom("Asap-Regular", size: 14, relativeTo: .callout))
                }
                .frame(width: 90)
                
                Divider()
                
                VStack (spacing: 2) {
                    Text(pokerSessionMatch?.hourlyRate.asCurrency() ?? "$0")
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
                    
                    Text("Hourly")
                        .foregroundStyle(.secondary)
                        .font(.custom("Asap-Regular", size: 14, relativeTo: .callout))
                }
                .frame(width: 90)
                
                Spacer()
            }
        }
        .animation(nil, value: rawSelectedDate)
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
    }
    
    var sleepImportance: some View {
        
        VStack (alignment: .leading) {
            
            Text("Importance of Sleep 🌙")
                .cardTitleStyle()
                .padding(.bottom)
            
            HStack {
                Text("""
                     The recommended sleep for adults older than 18 years is at least 7 hours per night.
                     
                     Sleep is essential to achieve the best state of physical and mental health. Research suggests that sleep plays an important role in learning, memory, mood, judgment, and overall it affects how well you perform when you're awake.
                     
                     When thinking about playing optimal poker, getting enough rest should be at or near the top of your priorities.
                     """)
                    .bodyStyle()
                
                Spacer()
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(
            Image("nightsky")
                .resizable()
                .clipped()
                .overlay(.ultraThinMaterial)
        )
        .cornerRadius(20)
        .padding(.top, 12)
        .padding(.bottom, activeSheet == .sleepAnalytics ? 0 : 40)
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
                if let selectedSleepMetric {
                    RuleMark(x: .value("Selected Metric", selectedSleepMetric.date))
                        .foregroundStyle(.gray.opacity(0.3))
                        .annotation(position: .top, spacing: 7, overflowResolution: .init(x: .fit(to: .chart))) {
                            Text("\(selectedSleepMetric.value, format: .number.rounded(increment: 0.1)) hrs")
                                .captionStyle()
                                .padding(10)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                }
                
                ForEach(hkManager.sleepData) { sleep in
                    BarMark(x: .value("Date", sleep.date), y: .value("Hours", sleep.value))
                        .foregroundStyle(calculateBarColor(healthMetric: sleep, viewModel: viewModel).gradient)
                        .opacity(rawSelectedDate == nil || sleep.date == selectedSleepMetric?.date ? 1.0 : 0.1)
                }
            }
            .sensoryFeedback(.selection, trigger: selectedSleepMetric?.value)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(preset: .aligned) {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), verticalSpacing: 10)
                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel {
                        if let value = value.as(Double.self), value != 0 {
                            Text("\(value, specifier: "%.0f")h")
                                .captionStyle()
                                .padding(.leading, 18)
                        }
                    }
                }
            }
            .padding(.leading, 6)
        }
        .overlay {
            if hkManager.sleepData.isEmpty {
                VStack {
                    ProgressView()
                        .padding(.bottom, 5)
                    Text("No sleep data to display.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                    Text("Grant permissions in iOS Settings.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 290)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
    }
    
    var oldSleepChart: some View {
        
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
                if let selectedSleepMetric {
                    RuleMark(x: .value("Selected Metric", selectedSleepMetric.date))
                        .foregroundStyle(.gray.opacity(0.3))
                        
                }
                
                ForEach(hkManager.sleepData) { sleep in
                    BarMark(x: .value("Date", sleep.date), y: .value("Hours", sleep.value))
                        .foregroundStyle(calculateBarColor(healthMetric: sleep, viewModel: viewModel).gradient)
                        .opacity(rawSelectedDate == nil || sleep.date == selectedSleepMetric?.date ? 1.0 : 0.1)
                }
            }
            
            .chartXAxis {
                AxisMarks(preset: .aligned) {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), verticalSpacing: 10)
                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel {
                        if let value = value.as(Double.self), value != 0 {
                            Text("\(value, specifier: "%.0f")h")
                                .captionStyle()
                                .padding(.leading, 18)
                        }
                    }
                }
            }
            .padding(.leading, 6)
        }
        .overlay {
            if hkManager.sleepData.isEmpty {
                VStack {
                    ProgressView()
                        .padding(.bottom, 5)
                    Text("No sleep data to display.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                    Text("Grant permissions in iOS Settings.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 290)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
    }
    
    private func handleAuthorizationChecksAndDataFetch() async {
        await hkManager.checkAuthorizationStatus()
        
        if hkManager.authorizationStatus != .notDetermined {
            do {
                try await hkManager.fetchSleepData()
            } catch let error as HKError {
                hkManager.errorMsg = error.description
            } catch {
                hkManager.errorMsg = HKError.unableToCompleteRequest.description
            }
        }
    }
    
    // Dynamically return red vs. green if the user won or lost money
    private func calculateBarColor(healthMetric: SleepMetric, viewModel: SessionsListViewModel) -> Color {
        
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
            return Color(.systemGray4).opacity(0.3)
        }
    }
    
    // Calculates how many sessions were played with less than 6 hours sleep since the start of the year
    private func countLowSleepSessions() -> Int {
        
        // These are ALL sessions where you've slept under 6 hours. Later we filter for only this year
        let sessions = viewModel.sessions.filter {
            guard let sleep = hkManager.sleepData.sleepHours(on: $0.date) else { return false }
            return sleep < 6
        }
        
        return sessions.filter({ $0.date.getYear() == Date().getYear() }).count
    }
    
    // Calculates your hourly rate when you get at least 6 hours of sleep
    private func performanceComparison() -> String {
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
                    return "No data available to compare performances yet."
                }
                return "Uh oh! All sessions played with under 6 hours of sleep. No baseline available."
            }

            let avgHourlyRateWithEnoughSleep = hourlyRateWithEnoughSleep / Double(countWithEnoughSleep)
            let avgHourlyRateWithLessSleep = countWithLessSleep > 0 ? hourlyRateWithLessSleep / Double(countWithLessSleep) : 0

            // Calculate percentage improvement
            if avgHourlyRateWithLessSleep != 0 {
                let improvement = ((avgHourlyRateWithEnoughSleep - avgHourlyRateWithLessSleep) / abs(avgHourlyRateWithLessSleep)) * 100
                return "Your hourly rate is \(improvement.formatted(.number.precision(.fractionLength(0))))% \(improvement > 0 ? "greater" : "worse") on days you sleep at least 6 hours."
            } else {
                return "Great! No sessions played with under 6 hours of sleep. No baseline available."
            }
    }
    
    private func avgSleep() -> String {
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
