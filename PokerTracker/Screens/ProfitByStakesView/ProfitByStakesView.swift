//
//  ProfitByGameView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/12/21.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct ProfitByStakesView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var subManager: SubscriptionManager
    @ObservedObject var viewModel: SessionsListViewModel
    
    @State private var yearFilter: String?
    @State private var metricFilter = "Total"
    @State private var showPaywall = false
    @State private var showDateFilter = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = .now
    @State private var showYearFilterTag: Bool = false
    
    var filteredSessions: [PokerSession] {
        
        var result = viewModel.sessions.filter({ $0.isTournament != true })
        
        if let yearFilter = yearFilter {
            result = result.filter({ $0.date.getYear() == yearFilter })
        }
        
        result = result.filter { session in
            let sessionDate = session.date
            return sessionDate >= startDate && sessionDate <= endDate
        }
        
        return result
    }
    var showCustomDatesTag: Bool {
        
        var show: Bool = false
        if startDate != viewModel.sessions.last?.date {
            show = true
        }
        
        return show
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    if showCustomDatesTag {
                        FilterTag(filterName: "Custom Dates")
                    }
                    
                    if let yearFilter {
                        FilterTag(filterName: "\(yearFilter)")
                    }
                }
                .padding(.top, showCustomDatesTag == true || yearFilter != nil ? 30 : 50)
                .padding(.trailing, 20)
                
                VStack (spacing: 10) {
                    
                    stakesTotals
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
                
                yearTotal
                
                let bestStakes = ueserBestStakes(sessions: filteredSessions)
                
                ToolTipView(image: "dollarsign.circle",
                            message: "Based on your hourly rates, your best game stakes are \(bestStakes).",
                            color: Color.donutChartPurple).padding(.top)
                
                if subManager.isSubscribed {
                    
                    stakesChart
                    
                } else {
                    
                    stakesChart
                        .blur(radius: 8)
                        .overlay {
                            Button {
                                showPaywall = true
                                
                            } label: {
                                Text("🔒 Tap to Upgrade")
                                    .buttonTextStyle()
                                    .frame(height: 55)
                                    .frame(width: UIScreen.main.bounds.width * 0.6)
                                    .background(Color.white)
                                    .foregroundColor(Color.black.opacity(0.8))
                                    .cornerRadius(30)
                                    .shadow(color: colorScheme == .dark ? .black : .black.opacity(0.25), radius: 20)
                            }
                        }
                }
                
                HStack {
                    Spacer()
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                    .dynamicTypeSize(.medium...DynamicTypeSize.large)
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                DismissButton()
                                    .padding()
                                    .onTapGesture {
                                        showPaywall = false
                                    }
                                Spacer()
                            }
                        }
                    }
            }
            .padding(.bottom, 60)
            .toolbar { headerInfo }
            .task {
                for await customerInfo in Purchases.shared.customerInfoStream {
                    showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                    await subManager.checkSubscriptionStatus()
                }
            }
        }
        .dynamicTypeSize(.xSmall...DynamicTypeSize.large)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Game Stakes"))
        .background(Color.brandBackground)
        .onAppear {
            startDate = viewModel.sessions.last?.date ?? Date().modifyDays(days: 150000)
            endDate = Date()
        }
    }
    
    var headerInfo: some View {
        
        VStack {
            
            HStack {
                
                let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
                
                Menu {
                    
                    Menu {
                        Picker("", selection: $yearFilter) {
                            ForEach(allYears, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                    } label: {
                        Text("Filter by Year")
                    }
                    
                    Button {
                        showDateFilter = true
                    } label: {
                        Text("Date Range")
                        Image(systemName: "calendar")
                    }
                    
                    Divider()
                    
                    Button {
                        resetAllFilters()
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
        .sheet(isPresented: $showDateFilter, content: {
            DateFilter(startDate: $startDate, endDate: $endDate)
                .presentationDetents([.height(350)])
                .presentationBackground(.ultraThinMaterial)
        })
        .onChange(of: startDate) { _ in
            yearFilter = nil
        }
    }
    
    var stakesTotals: some View {
        
        VStack (spacing: 10) {
            
            HStack {
                
                Spacer()
                
                Image(systemName: "dollarsign")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 55, alignment: .trailing)
                    .fontWeight(.bold)
                
                Image(systemName: "gauge.high")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 55, alignment: .trailing)
                    .fontWeight(.bold)
                
                Text("BB")
                    .font(.custom("Asap-Regular", size: 20, relativeTo: .body))
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 55, alignment: .trailing)
                    .fontWeight(.bold)
                
                Image(systemName: "clock")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 55, alignment: .trailing)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 10)
            
            Divider().padding(.bottom, 10)
            
            ForEach(viewModel.uniqueStakes, id: \.self) { stakes in
                
                HStack {
                    Text(stakes)
                        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
                    
                    Spacer()
                    
                    let total = viewModel.profitByStakes(stakes: stakes, sessions: filteredSessions)
                    let hourlyRate = hourlyByStakes(stakes: stakes, sessions: filteredSessions)
                    let hoursPlayed = viewModel.hoursAbbreviated(filteredSessions.filter({ $0.stakes == stakes }))
                    let bbPerHr = bbPerHourByStakes(stakes: stakes, sessions: filteredSessions.filter({ $0.stakes == stakes }))
                    
                    Text(total.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: total)
                        .frame(width: 57, alignment: .trailing)
                    
                    Text(hourlyRate.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: hourlyRate)
                        .frame(width: 57, alignment: .trailing)
                    
                    Text("\(bbPerHr, format: .number.precision(.fractionLength(2)))")
                        .frame(width: 57, alignment: .trailing)
                    
                    Text(hoursPlayed)
                        .frame(width: 57, alignment: .trailing)
                    
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
            }
        }
    }
    
    var yearTotal: some View {
        
        VStack (spacing: 7) {
            
            let bankrollTotalByFilter = bankrollByStakesFilters(sessions: filteredSessions)
            
            HStack {
                Image(systemName: "dollarsign")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Total")
                
                Spacer()
                
                Text(bankrollTotalByFilter, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bankrollTotalByFilter)
            }
            
            HStack {
                Image(systemName: "suit.club.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Sessions")
                
                Spacer()
                
                Text("\(filteredSessions.count)")
            }
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top, 15)
    }
    
    var stakesChart: some View {
        
        VStack {
            BarChartByStakes(viewModel: viewModel, showTitle: true, filteredSessions: filteredSessions)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
                .padding(.top, 15)
        }
    }
    
    private func hourlyByStakes(stakes: String, sessions: [PokerSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let totalHours = Float(sessions.filter{ $0.stakes == stakes }.map { $0.sessionDuration.hour ?? 0 }.reduce(0,+))
        let totalMinutes = Float(sessions.filter{ $0.stakes == stakes }.map { $0.sessionDuration.minute ?? 0 }.reduce(0,+))
        
        // Add up all the hours & minutes together to simply get a sum of hours
        let totalTime = totalHours + (totalMinutes / 60)
        let totalEarnings = sessions.filter({ $0.stakes == stakes }).map({ Int($0.profit) }).reduce(0,+)
        
        guard totalTime > 0 else { return 0 }
        if totalHours < 1 {
            return Int(Float(totalEarnings) / (totalMinutes / 60))
        } else {
            return Int(Float(totalEarnings) / totalTime)
        }
    }
    
    private func bbPerHourByStakes(stakes: String, sessions: [PokerSession]) -> Double {
        
        guard !sessions.isEmpty else { return 0 }
        guard !sessions.filter({ $0.stakes == stakes }).isEmpty else { return 0 }
        
        guard let lastSlashIndex = stakes.lastIndex(of: "/"),
              let bigBlind = Int(stakes[lastSlashIndex...].trimmingCharacters(in: .punctuationCharacters)) else {
              
            return 0
        }
        
        let hoursPlayed = sessions.filter({ $0.stakes == stakes }).map { $0.sessionDuration.durationInHours }.reduce(0, +)
        let profit = sessions.filter({ $0.stakes == stakes }).map { $0.profit }.reduce(0, +)
        let bigBlindsWon = Float(profit / bigBlind)
        
        return Double(bigBlindsWon / hoursPlayed)
    }
    
    private func ueserBestStakes(sessions: [PokerSession]) -> String {
        
        // Group sessions by stakes
        let stakesGrouped = Dictionary(grouping: sessions, by: { $0.stakes })
        
        // Create a dictionary to store the hourly rate by stakes
        var hourlyRatesByStakes: [String: Int] = [:]
        
        // Iterate through each stake group and calculate the hourly rate using your existing function
        for (stakes, sessionsAtStakes) in stakesGrouped {
            let hourlyRate = hourlyByStakes(stakes: stakes, sessions: sessionsAtStakes)
            hourlyRatesByStakes[stakes] = hourlyRate
        }
        
        // Check if we have any hourly rates to compare
        guard !hourlyRatesByStakes.isEmpty else {
            return "TBD"
        }
        
        // Find the stake with the best hourly rate
        let bestStakes = hourlyRatesByStakes.max { a, b in a.value < b.value }
        
        // Return the stake with the best hourly rate
        return bestStakes?.key ?? "TBD"
    }
    
    private func resetAllFilters() {
        yearFilter = nil
        startDate = viewModel.sessions.last?.date ?? Date().modifyDays(days: 150000)
        endDate = Date.now
    }
    
    private func bankrollByStakesFilters(sessions: [PokerSession]) -> Int {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        guard !sessions.isEmpty else { return 0 }
        
        var bankroll: Int {
            
            sessions.map { Int($0.profit) }.reduce(0, +)
        }

        return bankroll
    }
    
}

extension SessionsListViewModel {
    
    func hoursAbbreviated(_ sessions: [PokerSession]) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        guard !sessions.isEmpty else { return "0h" } // Return "0h" if there are no sessions
        
        let totalHours = sessions.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMins = sessions.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMins)
        let totalTime = Int(dateComponents.durationInHours)
        let formattedTotalTime = formatter.string(from: NSNumber(value: totalTime)) ?? "0"
        return "\(formattedTotalTime)h"
    }
}

struct ProfitByStakesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByStakesView(viewModel: SessionsListViewModel())
                .environmentObject(SubscriptionManager())
        }
        .preferredColorScheme(.dark)
    }
}
