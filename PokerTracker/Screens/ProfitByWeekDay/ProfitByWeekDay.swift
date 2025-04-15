//
//  ProfitByWeekDay.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/14/25.
//

import SwiftUI

struct ProfitByWeekDay: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var yearFilter: String = Date().getYear()
    @ObservedObject var vm: SessionsListViewModel
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                weekdayTotals
                
                toolTip
                
//                yearTotal
                
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
        .dynamicTypeSize(.xSmall...DynamicTypeSize.large)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Weekday Profits")
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItem {
                headerInfo
            }
            
            ToolbarItem(placement: .principal) {
                Text("Weekday Profits")
                    .font(.custom("Asap-Bold", size: 18))
            }
        }
    }
    
    private var headerInfo: some View {
        
        VStack {
            
            Menu {
                let allYears = vm.allSessions.map({ $0.date.getYear() }).uniqued()
                Menu {
                    Picker("", selection: $yearFilter) {
                        ForEach(allYears, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    
                } label: {
                    Text("Filter by Year")
                }
                
                Divider()
                
                Button {
                    yearFilter = Date().getYear()
                    
                } label: {
                    Text("Clear Filters")
                    Image(systemName: "x.circle")
                }
                
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
            .accentColor(Color.brandPrimary)
            .transaction { transaction in
                transaction.animation = nil
            }
        }
    }
    
    private var weekdays: [String] {
        return Calendar.current.weekdaySymbols
    }
    
    private var weekdayTotals: some View {
        
        VStack(spacing: 10) {
            
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

            // Iterate through weekdays instead of months
            ForEach(weekdays, id: \.self) { day in
                HStack {
                    Text(day)
                        .lineLimit(1)
                        .bold()

                    Spacer()

                    let filteredSessions = vm.allSessions.filter { $0.date.getYear() == yearFilter }
                    let total = filteredSessions.filter { $0.date.getWeekday() == day }.map { $0.profit }.reduce(0, +)
                    let hourlyRate = hourlyByWeekday(weekday: day, sessions: filteredSessions)
                    let hoursPlayed = vm.hoursAbbreviated(filteredSessions.filter { $0.date.getWeekday() == day })
                    
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
    
    private var toolTip: some View {
        
        Group {
            let filteredSessions = vm.allSessions.filter { $0.date.getYear() == yearFilter }
            if let bestDay = bestWeekdayComparison(from: filteredSessions) {
                ToolTipView(image: "chart.xyaxis.line", message: "Stick to \(bestDay.day)s, you perform \(Int(round(bestDay.improvementPercentage)))% better compared to other days.", color: .purple)
                    .padding(.top)
                
            } else {
                ToolTipView(image: "chart.xyaxis.line", message: "Not enough data yet to provide day-to-day analysis.", color: .purple)
                    .padding(.top)
            }
        }
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
    
    private func bestWeekdayComparison(from sessions: [PokerSession_v2]) -> (day: String, improvementPercentage: Double)? {
        // Exclude tournament sessions
        let nonTournamentSessions = sessions.filter { !$0.isTournament }
        guard !nonTournamentSessions.isEmpty else { return nil }
        
        // Group sessions by weekday. (Assumes you have a Date extension method getWeekday() that returns weekday names like "Monday".)
        let groupedByWeekday = Dictionary(grouping: nonTournamentSessions) { session in
            session.date.getWeekday()
        }
        
        // Compute the average hourly rate for each weekday using the session's hourlyRate property.
        let averages: [String: Double] = groupedByWeekday.mapValues { sessions in
            let totalHourlyRate = sessions.reduce(0) { $0 + $1.hourlyRate }
            return Double(totalHourlyRate) / Double(sessions.count)
        }
        
        // Need at least two weekdays to compare performance.
        guard averages.count > 1, let bestEntry = averages.max(by: { $0.value < $1.value }) else {
            return nil
        }
        
        let bestDay = bestEntry.key
        let bestAvg = bestEntry.value
        
        // Compute the average hourly rate for all weekdays except the best day.
        let otherDaysAverages = averages.filter { $0.key != bestDay }
        let combinedOtherAverage = otherDaysAverages.values.reduce(0, +) / Double(otherDaysAverages.count)
        
        // Guard against division by zero.
        guard combinedOtherAverage > 0 else { return nil }
        
        // Calculate the percentage improvement relative to the average of the other days.
        let improvementPercentage = ((bestAvg - combinedOtherAverage) / combinedOtherAverage) * 100
        return (day: bestDay, improvementPercentage: improvementPercentage)
    }
}

#Preview {
    NavigationView {
        ProfitByWeekDay(vm: SessionsListViewModel())
    }
}
