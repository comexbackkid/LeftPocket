//
//  MonthlyReportView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI
import TipKit

struct ProfitByMonth: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var yearFilter: String = Date().getYear()
    @State private var monthFilter: Int = Calendar.current.component(.month, from: Date())
    @ObservedObject var vm: SessionsListViewModel
    private let monthNames: [String] = {
            var formatter = DateFormatter()
            formatter.locale = .current
            return formatter.monthSymbols
        }()
    
    var body: some View {
        
        ScrollView {
                        
            VStack {
                
                tipView
                
                monthlyTotals
                    
                yearTotal
                
                monthlyChart
                
                perMonthBreakdown
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
        .dynamicTypeSize(.xSmall...DynamicTypeSize.large)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Monthly Snapshot")
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItem {
                headerInfo
            }
            
            ToolbarItem(placement: .principal) {
                Text("Monthly Snapshot")
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
    
    private var tipView: some View {
        
        Group {
            let monthlyReportTip = MonthlyReportTip()
            TipView(monthlyReportTip)
                .tipViewStyle(CustomTipViewStyle())
                .padding(.top)
        }
    }
    
    private var monthlyTotals: some View {
        
        VStack (spacing: 10) {
            
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
            
            Divider().padding(.bottom, 10)
            
            ForEach(vm.months, id: \.self) { month in
                HStack {
                    Text(month)
                        .lineLimit(1)
                        .bold()
                    
                    Spacer()
                    
                    let filteredMonths = vm.allSessions.filter({ $0.date.getYear() == yearFilter })
                    let total = filteredMonths.filter({ $0.date.getMonth() == month }).map { $0.profit }.reduce(0,+)
                    let hourlyRate = hourlyByMonth(month: month, sessions: filteredMonths)
                    let hoursPlayed = vm.hoursAbbreviated(filteredMonths.filter({ $0.date.getMonth() == month }))
                    
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
    
    private var yearTotal: some View {
        
        VStack (spacing: 7) {
            
            let filteredSessions = vm.sessions.filter({ $0.date.getYear() == yearFilter })
            let bankrollTotalByYear = vm.bankrollByYear(year: yearFilter, sessionFilter: .all)
            let totalHoursPlayed = filteredSessions.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
            
            HStack {
                Image(systemName: "dollarsign")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Total Profit")
                
                Spacer()
                
                Text(bankrollTotalByYear, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bankrollTotalByYear)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "clock")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Hours Played")
                
                Spacer()
                
                Text("\(totalHoursPlayed)h")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "suit.club.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Sessions Played")
                
                Spacer()
                
                Text("\(vm.sessions.filter({ $0.date.getYear() == yearFilter }).count)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
        .padding(20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top, 15)
    }
    
    @ViewBuilder
    private var monthlyChart: some View {
        
        let firstDay = Date.from(year: Int(yearFilter) ?? 2024, month: 1, day: 1)
        let lastDay = Date.from(year: Int(yearFilter) ?? 2024, month: 12, day: 31)
        BarChartByYear(showTitle: true, moreAxisMarks: false, firstDay: firstDay, lastDay: lastDay)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .frame(height: 300)
            .padding(.top, 15)
    }
    
    private var perMonthBreakdown: some View {
        
        VStack {
            
            HStack {
                VStack (alignment: .center, spacing: 3) {
                    Text("Results for")
                        .signInTitleStyle()
                    
                    Menu {
                        Picker("Month Picker", selection: $monthFilter) {
                            ForEach(1...12, id: \.self) { month in
                                Text(monthNames[month-1]).tag(month)
                            }
                        }
                        
                    } label: {
                        Text(monthNames[monthFilter-1] + " \(yearFilter)" + " ›")
                            .bodyStyle()
                            .tint(.brandPrimary)
                    }
                }
            }
            .padding(.vertical, 20)
            
            let filteredSessions = vm.allSessions.filter { Calendar.current.component(.month, from: $0.date) == monthFilter && $0.date.getYear() == yearFilter}
            
            BankrollLineChart(minimizeLineChart: .constant(true),
                              customDateRange: filteredSessions,
                              showTitle: true,
                              showYAxis: true,
                              showRangeSelector: false,
                              overlayAnnotation: false,
                              showToggleAndFilter: false)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .padding(.bottom)
            .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .frame(height: 200)
            
            let columns = [GridItem(spacing: 10), GridItem()]
            let profit = filteredSessions.map { $0.profit }.reduce(0, +).dashboardPlayerProfitShortHand(vm.userCurrency)
            let hourly = hourlyByMonth(month: monthNames[monthFilter-1], sessions: filteredSessions).currencyShortHand(vm.userCurrency)
            let totalHours = vm.hoursAbbreviated(filteredSessions)
            let winRatio = winRatioByMonth(sessions: filteredSessions)
            
            LazyVGrid(columns: columns, spacing: 20) {
                QuickMetricBox(title: "Total Profit", metric: profit, percentageChange: 0.0)
                    .padding(.top, 15)
                
                QuickMetricBox(title: "Hourly Rate", metric: hourly, percentageChange: 0.0)
                    .padding(.top, 15)
            }
            
            BarChartDailyCount(showTitle: true, dateRange: filteredSessions)
                .padding(20)
                .frame(height: 160)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(12)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
                .padding(.top, 15)
                .overlay {
                    if filteredSessions.isEmpty {
                        VStack {
                            Text("No chart data to display.")
                                .calloutStyle()
                                .foregroundStyle(.secondary)
                        }
                        .offset(y: 20)
                    }
                }
            
            LazyVGrid(columns: columns, spacing: 20) {
                QuickMetricBox(title: "Hours Played", metric: totalHours, percentageChange: 0.0)
                    .padding(.top, 15)
                
                QuickMetricBox(title: "Win Ratio", metric: winRatio, percentageChange: 0.0)
                    .padding(.top, 15)
            }
            .padding(.bottom, 60)
        }
    }
    
    private func hourlyByMonth(month: String, sessions: [PokerSession_v2]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let totalHours = Float(sessions.filter{ $0.date.getMonth() == month }.map { $0.sessionDuration.hour ?? 0 }.reduce(0,+))
        let totalMinutes = Float(sessions.filter{ $0.date.getMonth() == month }.map { $0.sessionDuration.minute ?? 0 }.reduce(0,+))
        
        // Add up all the hours & minutes together to simply get a sum of hours
        let totalTime = totalHours + (totalMinutes / 60)
        let totalEarnings = sessions.filter({ $0.date.getMonth() == month }).map({ Int($0.profit) }).reduce(0,+)
        
        guard totalTime > 0 else { return 0 }
        if totalHours < 1 {
            return Int(round(Float(totalEarnings) / (totalMinutes / 60)))
        } else {
            return Int(round(Float(totalEarnings) / totalTime))
        }
    }
    
    private func winRatioByMonth(sessions: [PokerSession_v2]) -> String {
        guard !sessions.isEmpty else { return "0%" }
        let profitableSessions = Double(sessions.filter { $0.profit > 0 }.count)
        let total = Double(sessions.count)
        let ratio = profitableSessions / total
        return ratio.asPercent()
    }
}

struct MonthlyReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByMonth(vm: SessionsListViewModel())
                .environmentObject(SessionsListViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
