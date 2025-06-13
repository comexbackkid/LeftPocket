//
//  SleepAnalytics.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/9/24.
//

import SwiftUI
import HealthKit
import HealthKitUI
import Charts
import RevenueCat
import RevenueCatUI
import TipKit

struct SleepAnalytics: View {
    
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var hkManager: HealthKitManager
    @EnvironmentObject var subManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingPermissionPrimingSheet = false
    @State private var trigger = false
    @State private var showError = false
    @State private var showPaywall = false
    @State private var howThisWorksPopup = false
    @State private var comparisonPopup = false
    @State private var rawSelectedDate: Date?
    @State private var chartData: [SleepMetric] = []
    @Binding var activeSheet: Sheet?

    // Using this Dictionary to speed up matching a green day or red day
    var dailyProfits: [Date: Int] {
        Dictionary(grouping: viewModel.allSessions, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.reduce(0) { $0 + $1.profit } }
    }
    var mostRecentSessionMatch: (session: PokerSession_v2, sleep: SleepMetric)? {
        guard let mostRecentSession = viewModel.allSessions.sorted(by: { $0.date > $1.date }).first else {
            return nil
        }
        
        // Normalize date to just the day (no time)
        let sessionDate = Calendar.current.startOfDay(for: mostRecentSession.date)
        
        // Try to find matching sleep metric for same day
        if let sleepMetric = hkManager.sleepData.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: sessionDate)
        }) {
            return (mostRecentSession, sleepMetric)
        } else {
            return (mostRecentSession, SleepMetric(date: sessionDate, value: 0)) // fallback if no sleep found
        }
    }
        
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                ScrollView {
                    
                    VStack {
                        
                        title
                        
                        instructions
                        
                        VStack (spacing: 22) {
                            
                            recentSleepSession
                            
                            if !subManager.isSubscribed { upgradeButton }

                            sleepChart
                                                        
                            lowSleepToolTip
                            
                            sleepPerformanceToolTip
                            
                            NavigationLink(destination: MindfulnessAnalytics()) {
                                mindfulnessCard
                            }
                            .buttonStyle(.plain)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("")
                        .padding(.bottom, 50)
                        .padding(.top)
                        .padding(.horizontal)
                        .padding(.bottom, activeSheet == .healthAnalytics ? 0 : 40)
                    }
                    .frame(maxWidth: .infinity)
                }
                .background(Color.brandBackground)
                
                if activeSheet == .healthAnalytics { dismissButton }
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
            .fullScreenCover(isPresented: $showPaywall, content: {
                PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                    .dynamicTypeSize(.large)
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                DismissButton()
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        showPaywall = false
                                }
                                Spacer()
                            }
                        }
                    }
            })
            .task {
                for await customerInfo in Purchases.shared.customerInfoStream {
                    showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                    await subManager.checkSubscriptionStatus()
                }
            }
        }
        .tint(.brandPrimary)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Health Analytics")
                .titleStyle()
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, activeSheet == .healthAnalytics ? 30 : 0)
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                Text("Gain a deeper understanding of how your health habits affect your poker game. Start by assessing your sleep numbers and mindful minutes below.")
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
                PopoverView(bodyText: "Left Pocket integrates sleep numbers recorded from your smart device, like an Apple Watch or Fitbit. If no sleep data is available, it defaults to using the estimated \"In Bed\" times generated by Apple's Health App.")
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
    
    var upgradeButton: some View {
        
        VStack {
            Button {
                showPaywall = true
                
            } label: {
                PrimaryButton(title: "Try Left Pocket Pro")
            }
        }
    }
    
    var lowSleepToolTip: some View {
        
        Group {
            if !subManager.isSubscribed {
                ToolTipView(image: "bed.double.fill",
                            message: "In the last month, you've played \(countLowSleepSessions()) session\(countLowSleepSessions() > 1 || countLowSleepSessions() < 1  ? "s" : "") under-rested.",
                            color: .donutChartOrange,
                            premium: true)
                .overlay {
                    if !subManager.isSubscribed {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Upgrade to Pro")
                                .calloutStyle()
                                .fontWeight(.black)
                                
                            
                        }
                        .padding(35)
                        .background(colorScheme == .dark ? Color.black.blur(radius: 25) : Color.white.blur(radius: 25))
                    }
                }
                .clipped()
                
            } else {
                ToolTipView(image: "bed.double.fill",
                            message: "In the last two months you've played \(countLowSleepSessions()) session\(countLowSleepSessions() > 1 || countLowSleepSessions() < 1  ? "s" : "") under-rested.",
                            color: .donutChartOrange,
                            premium: false)
            }
        }
    }
    
    var sleepPerformanceToolTip: some View {
        
        Group {
            if !subManager.isSubscribed {
                ToolTipView(image: "gauge",
                            message: performanceComparison(),
                            color: .chartAccent,
                            premium: true)
                .overlay {
                    if !subManager.isSubscribed {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Upgrade to Pro")
                                .calloutStyle()
                                .fontWeight(.black)
                                
                            
                        }
                        .padding(35)
                        .background(colorScheme == .dark ? Color.black.blur(radius: 25) : Color.white.blur(radius: 25))
                    }
                }
                .clipped()
                
            } else {
                ToolTipView(image: "gauge",
                            message: performanceComparison(),
                            color: .chartAccent,
                            premium: false)
            }
        }
    }
    
    var recentSleepSession: some View {
        
        VStack {
            
            HStack {
                Text("Most Recent Session")
                    .cardTitleStyle()
                    .padding(.bottom)
                
                Spacer()
            }
            
            HStack (alignment: .bottom) {
                
                Spacer()
                
                VStack (spacing: 2) {
                    
                    Text(mostRecentSessionMatch?.sleep.dayNoYear ?? "None")
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))

                    Text("Date")
                        .foregroundStyle(.secondary)
                        .font(.custom("Asap-Regular", size: 14, relativeTo: .callout))
                }
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                VStack (spacing: 2) {
                    
                    if let sleep = mostRecentSessionMatch?.sleep.value {
                        Text("\(sleep, format: .number.rounded(increment: 0.1)) hrs")
                            .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
                    } else {
                        Text("N/A")
                            .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
                    }
                    
                    Text("Sleep")
                        .foregroundStyle(.secondary)
                        .font(.custom("Asap-Regular", size: 14, relativeTo: .callout))
                }
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                VStack (spacing: 2) {
                    
                    Text(mostRecentSessionMatch?.session.hourlyRate.axisShortHand(viewModel.userCurrency) ?? "\(viewModel.userCurrency.symbol)0")
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
                    
                    Text("Hourly")
                        .foregroundStyle(.secondary)
                        .font(.custom("Asap-Regular", size: 14, relativeTo: .callout))
                }
                
                Spacer()
            }
        }
        .animation(nil, value: rawSelectedDate)
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    var mindfulnessCard: some View {
        
        VStack (alignment: .leading) {
            
            HStack (alignment: .top) {
                Image(systemName: "figure.mind.and.body")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color.white.gradient)
                
                VStack (alignment: .leading) {
                    Text("Mindfulness")
                        .cardTitleStyle()
                        .foregroundStyle(Color.white)
                    
                    Text("Establish your focus & headspace before you play.")
                        .calloutStyle()
                        .foregroundStyle(Color.white)
                        .opacity(0.5)
                }
                .padding(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .bold()
                    .foregroundStyle(Color.white)
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(
            Image("nightsky")
                .centerCropped()
                .overlay {
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .opacity(0.75)
                }
        )
        .cornerRadius(12)
    }
    
    var dismissButton: some View {
        
        VStack {
            
            HStack {
                
                Spacer()
                
                DismissButton()
                    .padding(.trailing, 10)
                    .padding(.top, 20)
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        dismiss()
                    }
            }
            
            Spacer()
        }
    }
    
    var sleepChart: some View {
        
        VStack {
            VStack (alignment: .leading, spacing: 3) {
                HStack {
                    Text("Last 60 Days of Sleep")
                        .cardTitleStyle()
                    
                    Spacer()
                }
                
                Text("Avg " + avgSleep() + " hrs")
                    .subHeadlineStyle()
                    .foregroundStyle(.secondary)
                    .animation(nil, value: avgSleep())
            }
            .padding(.bottom, 40)
            
            Chart {
                ForEach(chartData) { sleep in
//                ForEach(SleepMetric.MockData) { sleep in
//                    let day = Calendar.current.startOfDay(for: sleep.date)
                    BarMark(x: .value("Date", sleep.date, unit: .day), y: .value("Hours", sleep.value), width: .fixed(20))
                        .foregroundStyle(calculateBarColor(for: sleep))
                        .cornerRadius(3)
                    
                    RuleMark(y: .value("Average", Double(avgSleep()) ?? 0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(Color.donutChartOrange)
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Avg \(avgSleep())")
                                .font(.caption)
                                .foregroundStyle(Color.donutChartOrange)
                                .padding(.bottom, 10)
                        }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 86400*7)
            .chartScrollPosition(initialX: Date().modifyDays(days: -1))
            .chartScrollTargetBehavior(.paging)
            .chartXSelection(value: $rawSelectedDate)
            .chartXAxis {
                AxisMarks(preset: .aligned) {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), verticalSpacing: 10)
                        .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                }
            }
            .chartYAxis {
                AxisMarks() { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.33))
                    
                    AxisValueLabel {
                        if let value = value.as(Double.self), value != 0 {
                            Text("\(value, specifier: "%.0f")h")
                                .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                                .padding(.leading, 18)
                        }
                    }
                }
            }
            .padding(.leading, 6)
        }
        .overlay {
            if chartData.isEmpty {
                VStack {
                    Text("No sleep data to display.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                    
                    Text("Check permissions in iOS Settings.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(height: 290)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .popoverTip(SleepTip(), arrowEdge: .bottom)
        .tipViewStyle(CustomTipViewStyle())
    }
    
    private func handleAuthorizationChecksAndDataFetch() async {
        
        await hkManager.checkAuthorizationStatus()
        
        if hkManager.authorizationStatus != .notDetermined {
            do {
                try await hkManager.fetchSleepData()
                chartData = hkManager.sleepData
                hkManager.totalMindfulMinutesPerDay = try await hkManager.fetchDailyMindfulMinutesData()
                
            } catch let error as HKError {
                hkManager.errorMsg = error.description
                
            } catch {
                hkManager.errorMsg = HKError.unableToCompleteRequest.description
            }
        }
    }
    
    // Dynamically return red vs. green if the user won or lost money
    private func calculateBarColor(for healthMetric: SleepMetric) -> Color {
        let date = Calendar.current.startOfDay(for: healthMetric.date)
        let profit = dailyProfits[date] ?? 0
        
        if profit > 0 {
            return .green
        } else if profit < 0 {
            return .red
        } else {
            return Color(.systemGray4).opacity(0.7)
        }
    }
    
    // Calculates how many sessions were played with less than 6 hours of sleep in the last 30 days
    private func countLowSleepSessions() -> Int {
        
        // Calculate the date 30 days ago
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date())!
        
        // Filter sessions where you've slept under 6 hours
        let sessions = viewModel.allSessions.filter {
            guard let sleep = hkManager.sleepData.sleepHours(on: $0.date) else { return false }
            return sleep < 6
        }
        
        // Further filter sessions that occurred in the last 30 days
        return sessions.filter { $0.date >= sixtyDaysAgo }.count
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

        for session in viewModel.allSessions {
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
                return "Uh oh! All your sessions have been with less than 6 hours of sleep."
            }

            let avgHourlyRateWithEnoughSleep = hourlyRateWithEnoughSleep / Double(countWithEnoughSleep)
            let avgHourlyRateWithLessSleep = countWithLessSleep > 0 ? hourlyRateWithLessSleep / Double(countWithLessSleep) : 0

            // Calculate percentage improvement
            if avgHourlyRateWithLessSleep != 0 {
                let improvement = ((avgHourlyRateWithEnoughSleep - avgHourlyRateWithLessSleep) / abs(avgHourlyRateWithLessSleep)) * 100
                return "Your hourly rate is \(improvement.formatted(.number.precision(.fractionLength(0))))% \(improvement > 0 ? "greater" : "worse") on days you sleep at least 6 hours."
            } else {
                return "Great! No sessions played with less than 6 hours of sleep."
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
    SleepAnalytics(activeSheet: .constant(.healthAnalytics))
        .environmentObject(SessionsListViewModel())
        .environmentObject(HealthKitManager())
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}
