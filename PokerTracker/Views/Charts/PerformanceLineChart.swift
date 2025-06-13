//
//  PerformanceLineChart.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 11/8/24.
//

import SwiftUI
import Charts
import RevenueCat
import RevenueCatUI

struct PerformanceLineChart: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var selectedMonth: Date?
    @State private var metricFilter: MetricFilter = .hourly
    @State private var showPaywall = false
    let firstDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 1, day: 1)
    let lastDay: Date = Date.from(year: Int(Date().getYear()) ?? 2024, month: 12, day: 31)
    var chartData: [(Date, Double)] {
        switch metricFilter {
        case .hourly: return sessionAverageHourlyRateByMonth.map { ($0.month, Double($0.averageHourlyRate)) }
        case .winRate: return sessionWinRateByMonthData.map { ($0.month, $0.winRate) }
        case .bbRate: return sessionBbWonByMonth.map { ( $0.month, $0.bbWon ) }
        }
    }
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 3) {
            
            HStack {
                
                Text("\(metricFilter.description) Over Time")
                    .cardTitleStyle()
                
                Spacer()
                
                filterButton
            }

            let areaGradient = LinearGradient(colors: [.donutChartRed, .clear], startPoint: .top, endPoint: .bottom)
            let lineGradient = LinearGradient(colors: [.donutChartRed, .pink], startPoint: .topTrailing, endPoint: .bottomLeading)
            let month = Text(selectedMonth?.getMonth() ?? "No Selection")
            
            Group {
                if selectedMonth != nil {
                    HStack(spacing: 5) {
                        textAnnotation()
                        Text("in \(month)")
                            .font(.custom("Asap-Medium", size: 17))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No Selection")
                        .foregroundStyle(.secondary)
                        .font(.custom("Asap-Medium", size: 17))
                }
            }
            .animation(nil, value: selectedMonth)
            
            Chart {
                ForEach(chartData, id: \.0) { (month, value) in
                    LineMark(x: .value("Month", month, unit: .month), y: .value("Value", value))
                        .foregroundStyle(lineGradient)
                        .lineStyle(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                    
                    AreaMark(x: .value("Month", month, unit: .month), y: .value("Value", value))
                        .foregroundStyle(areaGradient)
                        .interpolationMethod(.catmullRom)
                        .opacity(0.2)
                }
                
                if let selectedMonth {
                    
                    RuleMark(x: .value("Selected Month", selectedMonth, unit: .month))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6]))
                        .foregroundStyle(.gray.opacity(0.33))
                        .zIndex(-1)
                    
                    PointMark(x: .value("Month", selectedMonth, unit: .month), y: .value("Value", valueAnnotation ?? 0))
                        .foregroundStyle(colorScheme == .dark ? Color.brandWhite : Color.black)
                        .symbolSize(100)
                    PointMark(x: .value("Month", selectedMonth, unit: .month), y: .value("Value", valueAnnotation ?? 0))
                        .foregroundStyle(colorScheme == .dark ? Color.black : .white)
                        .symbolSize(40)
                }
            }
            .chartXSelection(value: $selectedMonth.animation(.easeInOut))
            .sensoryFeedback(.selection, trigger: valueAnnotation)
            .chartXScale(domain: [firstDay, lastDay])
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        switch metricFilter {
                        case .hourly:
                            if let intValue = value.as(Int.self) {
                                Text(intValue.axisShortHand(viewModel.userCurrency))
                                    .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                                    .padding(.trailing, 15)
                            }
                        case .winRate:
                            if let doubleValue = value.as(Double.self) {
                                Text(doubleValue.asPercent())
                                    .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                                    .padding(.trailing, 15)
                            }
                        case .bbRate:
                            if let doubleValue = value.as(Double.self) {
                                Text("\(doubleValue, specifier: "%.0f")")
                                    .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                                    .padding(.trailing, 15)
                            }
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2, 4]))
                        .foregroundStyle(.gray.opacity(chartData.isEmpty ? 0.0 : 0.33))
                    AxisValueLabel(format: .dateTime.month(.abbreviated),
                                   horizontalSpacing: 0,
                                   verticalSpacing: 15).font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                }
            }
            .overlay {
                if chartData.isEmpty {
                    VStack {
                        Text("No chart data to display.")
                            .calloutStyle()
                            .foregroundStyle(.secondary)
                    }
                    .offset(y: -20)
                }
            }
            .padding(.top, 30)
            .blur(radius: subManager.isSubscribed ? 0 : 4)
            .allowsHitTesting(subManager.isSubscribed ? true : false)
            .overlay {
                if !subManager.isSubscribed {
                    Button {
                       showPaywall = true
                    } label: {
                        Text("Try Left Pocket Pro")
                            .buttonTextStyle()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(Color.black.opacity(0.8))
                            .cornerRadius(30)
                            .shadow(color: colorScheme == .dark ? .black : .black.opacity(0.25), radius: 20)
                    }
                    .padding(.horizontal)
                }
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
    }
    
    var filterButton: some View {
        
        Menu {
            Picker("", selection: $metricFilter) {
                ForEach(MetricFilter.allCases, id: \.self) {
                    Text($0.description).tag($0)
                }
            }
        } label: {
            Text(metricFilter.description + " ›")
                .bodyStyle()
        }
        .tint(.brandPrimary)
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    var valueAnnotation: Double? {
        guard let selectedMonth = selectedMonth else { return nil }
        return valueByMonth(month: selectedMonth, data: viewModel.allSessions.filter({ $0.isTournament != true }))
    }
    
    var sessionAverageHourlyRateByMonth: [(month: Date, averageHourlyRate: Int)] {
        sessionsAverageHourlyRateByMonth(sessions: viewModel.allSessions, cashOnly: true)
    }
    
    var sessionWinRateByMonthData: [(month: Date, winRate: Double)] {
        sessionsWinRateByMonth(sessions: viewModel.allSessions, cashOnly: true)
    }
    
    var sessionBbWonByMonth: [(month: Date, bbWon: Double)] {
        sessionsBbWon(sessions: viewModel.allSessions, cashOnly: true)
    }

    func sessionsAverageHourlyRateByMonth(sessions: [PokerSession_v2], cashOnly: Bool) -> [(month: Date, averageHourlyRate: Int)] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let filtered = (cashOnly ? sessions.filter { !$0.isTournament } : sessions).filter { Calendar.current.component(.year, from: $0.date) == currentYear }
        let grouped = Dictionary(grouping: filtered) { Calendar.current.startOfMonth(for: $0.date) }
        let results = grouped.map { month, monthSessions -> (Date, Int) in
            let totalHours = monthSessions.reduce(0.0) { runningTotal, session in
                let h = Double(session.sessionDuration.hour ?? 0)
                let m = Double(session.sessionDuration.minute ?? 0)
                return runningTotal + h + (m / 60)
            }
            
            let totalEarnings = monthSessions.reduce(0.0) { runningTotal, session in
                runningTotal + Double(session.profit)
            }
            
            let averageRate = totalHours > 0 ? Int(round(totalEarnings / totalHours)) : 0
            return (month, averageRate)
        }
        
        return results.sorted { $0.0 < $1.0 }
    }
    
    func sessionsWinRateByMonth(sessions: [PokerSession_v2], cashOnly: Bool) -> [(month: Date, winRate: Double)] {
        
        var monthlyWinRates: [Date: (wins: Int, total: Int)] = [:]
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let filteredSessions = cashOnly ? sessions.filter { $0.isTournament != true } : sessions
        
        for session in filteredSessions {
            let yearOfSession = Calendar.current.component(.year, from: session.date)
            
            if yearOfSession == currentYear {
                let month = Calendar.current.startOfMonth(for: session.date)
                
                if session.profit > 0 {
                    monthlyWinRates[month, default: (0,0)].wins += 1
                }
                
                monthlyWinRates[month, default: (0,0)].total += 1
            }
        }
        
        // Calculate the win rate for each month
        return monthlyWinRates.map { month, data in
            let winRate = data.total > 0 ? Double(data.wins) / Double(data.total) : 0.0
            return (month, winRate)
        }
        .sorted { $0.0 < $1.0 }
    }
    
    func sessionsBbWon(sessions: [PokerSession_v2], cashOnly: Bool) -> [(month: Date, bbWon: Double)] {
        
        var monthlyBbWon: [Date: [Double]] = [:]
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let filteredSessions = cashOnly ? sessions.filter { $0.isTournament != true } : sessions
        
        for session in filteredSessions {
            let yearOfSession = Calendar.current.component(.year, from: session.date)
            
            // Check if the session is from the current year
            if yearOfSession == currentYear {
                let month = Calendar.current.startOfMonth(for: session.date)
                
                // Append the hourly rate for the session to the month's array
                monthlyBbWon[month, default: []].append(session.bigBlindsWon)
            }
        }
        
        return monthlyBbWon.map { month, value in
            let totalBbWon = value.isEmpty ? 0 : value.reduce(0, +)
            return (month, totalBbWon)
        }
        .sorted { $0.0 < $1.0 }
    }
    
    /// Helper function just for annotation
    func averageHourlyRateForAnnotation(for month: Date, sessions: [PokerSession_v2], cashOnly: Bool) -> Double {
        let monthSessions = (cashOnly ? sessions.filter { !$0.isTournament } : sessions)
            .filter { Calendar.current.startOfMonth(for: $0.date) == month }
        let totalHours = monthSessions.reduce(0.0) { total, session in
            total
              + Double(session.sessionDuration.hour ?? 0)
              + (Double(session.sessionDuration.minute ?? 0) / 60)
        }
        let totalEarnings = monthSessions.reduce(0.0) { total, session in
            total + Double(session.profit)
        }
        guard totalHours > 0 else { return 0 }
        return totalEarnings / totalHours
    }
    
    /// Switches between spitting out Double values depending on the metric switcher in the chart
    func valueByMonth(month: Date, data: [PokerSession_v2]) -> Double {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // 1) Filter down to sessions in the same year & same month as `month`
        let filteredSessions = data.filter {
            calendar.component(.year,  from: $0.date) == currentYear
            && calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        
        // 2) Compute total time in hours
        let totalHours = filteredSessions.reduce(0.0) { running, session in
            let h = Double(session.sessionDuration.hour ?? 0)
            let m = Double(session.sessionDuration.minute ?? 0) / 60
            return running + h + m
        }
        
        // 3) Compute total earnings
        let totalEarnings = filteredSessions.reduce(0.0) { running, session in
            running + Double(session.profit)
        }
        
        let averageHourly = totalHours > 0 ? totalEarnings / totalHours : 0
        let winRate = filteredSessions.isEmpty ? 0 : Double(filteredSessions.filter { $0.profit > 0 }.count) / Double(filteredSessions.count)
        let bbWon = filteredSessions.isEmpty ? Double.nan : filteredSessions.reduce(0.0) { $0 + Double($1.bigBlindsWon) }
        
        switch metricFilter {
        case .hourly:  return averageHourly
        case .winRate: return winRate
        case .bbRate:  return bbWon
        }
    }
    
    func textAnnotation() -> some View {
        
        let amountText: Text? = valueAnnotation.map { value in
            let validValue = value.isFinite ? value : 0
            switch metricFilter {
            case .hourly:
                return Text(validValue, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(validValue > 0 ? colorScheme == .dark ? Color.lightGreen : .green : validValue < 0 ? .red : .secondary)
                    .font(.custom("Asap-Medium", size: 17))
            case .winRate:
                return Text(validValue, format: .percent.precision(.fractionLength(0)))
                    .foregroundColor(validValue > 0 ? colorScheme == .dark ? Color.lightGreen : .green : validValue < 0 ? .red : .secondary)
                    .font(.custom("Asap-Medium", size: 17))
            case .bbRate:
                return Text(validValue, format: .number.precision(.fractionLength(2)))
                    .foregroundColor(validValue > 0 ? colorScheme == .dark ? Color.lightGreen : .green : validValue < 0 ? .red : .secondary)
                    .font(.custom("Asap-Medium", size: 17))
            }
        }
        
        return amountText
    }
    
    enum MetricFilter: String, CaseIterable {
        case hourly, winRate, bbRate
        
        var description: String {
            switch self {
            case .hourly: return "Hourly"
            case .winRate: return "Win Ratio"
            case .bbRate: return "BB Won"
            }
        }
    }
}

#Preview {
    PerformanceLineChart()
        .frame(height: 400)
        .padding()
        .environmentObject(SessionsListViewModel())
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}
