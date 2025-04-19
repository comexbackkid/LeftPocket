//
//  ProfitByWeekDay.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/14/25.
//

import SwiftUI
import TipKit

struct ProfitByWeekDay: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var yearFilter: String? = nil
    @ObservedObject var vm: SessionsListViewModel
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                weekdaysTip
                
                weekdayTotals
                
                toolTip
                
                dayOfWeekChart
                                
            }
            .padding(.horizontal)
            .padding(.bottom, 60)
        }
        .background(Color.brandBackground)
        .dynamicTypeSize(.xSmall...DynamicTypeSize.large)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Weekday Statistics")
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItem {
                headerInfo
            }
            
            ToolbarItem(placement: .principal) {
                Text("Weekday Statistics")
                    .font(.custom("Asap-Bold", size: 18))
            }
        }
    }
    
    private var headerInfo: some View {
        
        Menu {
            let allYears = vm.allSessions.map { $0.date.getYear() }.uniqued().sorted()
            
            Menu {
                withAnimation {
                    Picker("Year Filter", selection: $yearFilter) {

                        Text("All").tag(String?.none)
                        
                        ForEach(allYears, id: \.self) { year in
                            Text(year).tag(String?.some(year))
                        }
                    }
                }
                
            } label: {
                Text("Filter by Year")
            }
            
            Divider()
            
            Button {
                yearFilter = nil
                
            } label: {
                Text("Clear Filters")
                Image(systemName: "x.circle")
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .accentColor(Color.brandPrimary)
        .transaction { $0.animation = nil }
    }
    
    private var weekdays: [String] {
        return Calendar.current.weekdaySymbols
    }
    
    private var weekdayTotals: some View {
        
        let filteredSessions = vm.allSessions
            .filter { session in
                (yearFilter == nil || session.date.getYear() == yearFilter!)
                && session.isTournament == false
            }
        
        return VStack(spacing: 10) {
            
            HStack {
                
                Spacer()
                
                Image(systemName: "dollarsign")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 60, alignment: .trailing)
                    .fontWeight(.bold)
                
                Image(systemName: "gauge.high")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 60, alignment: .trailing)
                    .fontWeight(.bold)
                
                Image(systemName: "clock")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 60, alignment: .trailing)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 10)
            
            Divider()
                .padding(.bottom, 10)
            
            ForEach(weekdays, id: \.self) { day in
                HStack {
                    Text(day)
                        .lineLimit(1)
                        .bold()
                    
                    Spacer()
                    
                    let daySessions = filteredSessions.filter { $0.date.getWeekday() == day }
                    let total = daySessions.map(\.profit).reduce(0,+)
                    let hourlyRate = hourlyByWeekday(weekday: day, sessions: daySessions)
                    let hoursPlayed = vm.hoursAbbreviated(daySessions)
                    
                    Text(total == 0 ? "-" : total.axisShortHand(vm.userCurrency))
                        .profitColor(total: total)
                        .frame(width: 62, alignment: .trailing)
                    
                    Text(hourlyRate == 0 ? "-" : hourlyRate.axisShortHand(vm.userCurrency))
                        .profitColor(total: hourlyRate)
                        .frame(width: 62, alignment: .trailing)
                    
                    Text(hoursPlayed == "0h" ? "-" : hoursPlayed)
                        .foregroundColor(hoursPlayed == "0h" ? Color(.systemGray) : .primary)
                        .frame(width: 62, alignment: .trailing)
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
            }
        }
        .padding(20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top)
    }
    
    private var weekdaysTip: some View {
        
        Group {
            let weekdaysTip = WeekdaysTip()
            TipView(weekdaysTip)
                .tipViewStyle(CustomTipViewStyle())
                .padding(.top)
        }
    }
    
    private var toolTip: some View {
        
        Group {
            let filteredSessions = vm.allSessions.filter {( yearFilter == nil || $0.date.getYear() == yearFilter!) && !$0.isTournament }
            
            if let bestDay = bestWeekdayComparisonUsingHourlyFunction(from: filteredSessions) {
                ToolTipView(
                    image: "chart.xyaxis.line",
                    message: "Stick to \(bestDay.bestDay)s, you perform \(Int(round(bestDay.improvementPercentage)))% better compared to other days.",
                    color: .purple
                )
                .padding(.top)
                
            } else {
                ToolTipView(image: "chart.xyaxis.line", message: "Not enough data yet to provide day-to-day analysis.", color: .purple)
                    .padding(.top)
            }
        }
    }
    
    private var dayOfWeekChart: some View {
        
        let chartData = vm.allSessions.filter {( yearFilter == nil || $0.date.getYear() == yearFilter!) && !$0.isTournament }
        
        return BarChartByWeekDay(showTitle: true, dateRange: chartData)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .frame(height: 250)
            .padding(.top, 15)
        
    }

    private func hourlyByWeekday(weekday: String, sessions: [PokerSession_v2]) -> Int {
        // Filter sessions that match the provided weekday
        let sessionsForWeekday = sessions.filter { $0.date.getWeekday() == weekday }
        guard !sessionsForWeekday.isEmpty else { return 0 }
        
        // Calculate total time
        let totalHours = Float(sessionsForWeekday.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +))
        let totalMinutes = Float(sessionsForWeekday.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +))
        
        let totalTime = totalHours + (totalMinutes / 60)
        let totalEarnings = sessionsForWeekday.map { Int($0.profit) }.reduce(0, +)
        
        guard totalTime > 0 else { return 0 }
        
        if totalHours < 1 {
            return Int(round(Float(totalEarnings) / (totalMinutes / 60)))
        } else {
            return Int(round(Float(totalEarnings) / totalTime))
        }
    }
    
    private func bestWeekdayComparisonUsingHourlyFunction(from sessions: [PokerSession_v2]) -> (bestDay: String, improvementPercentage: Double)? {

        let weekdays = Calendar.current.weekdaySymbols
        
        var dayRates: [(day: String, rate: Int)] = []
        for day in weekdays {
            let rate = hourlyByWeekday(weekday: day, sessions: sessions)
            dayRates.append((day: day, rate: rate))
        }
        
        // Ensure that there is at least one day with a non-zero rate.
        guard let bestEntry = dayRates.max(by: { $0.rate < $1.rate }), bestEntry.rate > 0 else {
            return nil
        }
        
        let bestDay = bestEntry.day
        let bestRate = Double(bestEntry.rate)
        
        let otherDays = dayRates.filter { $0.day != bestDay }
        guard !otherDays.isEmpty else { return nil }
        
        let validOtherDays = otherDays.filter { $0.rate > 0 }
        guard !validOtherDays.isEmpty else { return nil }
        let averageOtherRate = Double(validOtherDays.map { $0.rate }.reduce(0, +)) / Double(validOtherDays.count)
        
        let denominator = (bestRate + averageOtherRate) / 2
        guard denominator != 0 else { return nil }
        
        let improvementPercentage = ((bestRate - averageOtherRate) / denominator) * 100
        return (bestDay, improvementPercentage)
    }
}

#Preview {
    NavigationView {
        ProfitByWeekDay(vm: SessionsListViewModel())
    }
}
