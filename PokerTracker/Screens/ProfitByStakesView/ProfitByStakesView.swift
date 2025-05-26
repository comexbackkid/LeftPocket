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
    
    @State private var yearFilter: String? = nil
    @State private var metricFilter = "Total"
    @State private var showPaywall = false
    @State private var showDateFilter = false
    @State private var startDateFilter: Date? = nil
    @State private var endDateFilter: Date? = nil
    
    var filteredSessions: [PokerSession_v2] {

        let allCashSessions = viewModel.sessions + viewModel.bankrolls.flatMap(\.sessions)
        let onlyCash = allCashSessions.filter { !$0.isTournament }
        
        return onlyCash.filter { session in
            let date = session.date
            let startOK = startDateFilter.map { date >= $0 } ?? true
            let endOK = endDateFilter.map { date <= $0 } ?? true
            // Only check for matching year if yearFilter is not nil.
            let yearMatches = yearFilter.map { session.date.getYear() == $0 } ?? true
            return startOK && endOK && yearMatches
        }
    }
    var showCustomDatesTag: Bool { startDateFilter != nil }
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    if showCustomDatesTag {
                        FilterTag(type: "Filter", filterName: "Custom Dates")
                    }
                    
                    if let yearFilter {
                        FilterTag(type: "Filter", filterName: "\(yearFilter)")
                    }
                }
                .padding(.top, showCustomDatesTag == true || yearFilter != nil ? 30 : 10)
                
                stakesTotals
                
                yearTotal
                
                let bestStakes = ueserBestStakes(sessions: filteredSessions)
                
                ToolTipView(image: "dollarsign.circle",
                            message: "Based on your hourly rates, your best game stakes are \(bestStakes).",
                            color: Color.donutChartPurple).padding(.top)
                
                if subManager.isSubscribed {
                    
                    stakesChart
                    
                } else {
                    stakesChart
                        .blur(radius: 6)
                        .overlay {
                            Button {
                                showPaywall = true
                                
                            } label: {
                                Text("Try Left Pocket Pro")
                                    .buttonTextStyle()
                                    .frame(height: 50)
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
            .padding(.horizontal)
            .padding(.bottom, 60)
            .toolbar {
                ToolbarItem {
                    headerInfo
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Game Stakes")
                        .font(.custom("Asap-Bold", size: 18))
                }
            }
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
    }
    
    var headerInfo: some View {
        
        VStack {
            
            Menu {
                let allYears = viewModel.allSessions.map({ $0.date.getYear() }).uniqued()
                
                Menu {
                    Picker("Year Filter", selection: $yearFilter) {
                        
                        Text("All").tag(String?.none)
                        
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
        .sheet(isPresented: $showDateFilter, content: {
            DateFilter(startDate: $startDateFilter, endDate: $endDateFilter)
                .presentationDetents([.height(350)])
                .presentationBackground(.ultraThinMaterial)
                .presentationDragIndicator(.visible)
        })
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
            
            let uniqueStakes = Array(Set(viewModel.allCashSessions().map { $0.stakes }))
            ForEach(uniqueStakes, id: \.self) { stakes in
                
                HStack {
                    Text(stakes)
                        .lineLimit(1)
                        .bold()
                    
                    Spacer()
                    
                    let total = viewModel.profitByStakes(stakes: stakes, sessions: filteredSessions)
                    let hourlyRate = hourlyByStakes(stakes: stakes, sessions: filteredSessions)
                    let hoursPlayed = viewModel.hoursAbbreviated(filteredSessions.filter({ $0.stakes == stakes }))
                    let bbPerHr = bbPerHourByStakes(stakes: stakes, sessions: filteredSessions.filter({ $0.stakes == stakes }))
                    
                    Text(total == 0 ? "-" : total.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: total)
                        .frame(width: 57, alignment: .trailing)
                    
                    Text(hourlyRate == 0 ? "-" : hourlyRate.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: hourlyRate)
                        .frame(width: 57, alignment: .trailing)
                    
                    Text(bbPerHr == 0 ? "-" : "\(bbPerHr, format: .number.precision(.fractionLength(2)))")
                        .frame(width: 57, alignment: .trailing)
                    
                    Text(hoursPlayed == "0h" ? "-" : hoursPlayed)
                        .frame(width: 57, alignment: .trailing)
                    
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
            }
        }
        .padding(20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    var yearTotal: some View {
        
        VStack (spacing: 7) {
            
            let profitTotalByFilter = bankrollByStakesFilters(sessions: filteredSessions)
            
            HStack {
                Image(systemName: "dollarsign")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Total")
                
                Spacer()
                
                Text(profitTotalByFilter, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: profitTotalByFilter)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "suit.club.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Sessions")
                
                Spacer()
                
                Text("\(filteredSessions.count)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            let averageBuyIn = averageBuyIn(sessions: filteredSessions)
            
            HStack {
                Image(systemName: "cart.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Avg. Buy In")
                
                Spacer()
                
                Text(averageBuyIn, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            let punts = calculatePunts(sessions: filteredSessions)
            
            HStack {
                Image(systemName: "football.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Punts")
                
                Spacer()
                
                Text("\(punts)")
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
    
    var stakesChart: some View {
        VStack {
            BarChartByStakes(viewModel: viewModel, showTitle: true, filteredSessions: filteredSessions)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(12)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
                .padding(.top, 15)
        }
    }
    
    private func averageBuyIn(sessions: [PokerSession_v2]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let totalBuyIns = Float(sessions.map({ $0.buyIn }).reduce(0, +))
        let sessionCount = Float(sessions.count)
        let avgBuyIn = totalBuyIns / sessionCount
        return Int(avgBuyIn)
    }
    
    private func calculatePunts(sessions: [PokerSession_v2]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.filter { $0.cashOut == 0 }.count
    }
    
    private func hourlyByStakes(stakes: String, sessions: [PokerSession_v2]) -> Int {
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
    
    private func bbPerHourByStakes(stakes: String, sessions: [PokerSession_v2]) -> Double {
        
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
    
    private func ueserBestStakes(sessions: [PokerSession_v2]) -> String {
        
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
        startDateFilter = nil
        endDateFilter = nil
    }
    
    private func bankrollByStakesFilters(sessions: [PokerSession_v2]) -> Int {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        guard !sessions.isEmpty else { return 0 }
        var bankroll: Int { sessions.map { Int($0.profit) }.reduce(0, +) }

        return bankroll
    }
}

extension SessionsListViewModel {
    
    func hoursAbbreviated(_ sessions: [PokerSession_v2]) -> String {
        
        guard !sessions.isEmpty else { return "0h" }
        
        let totalMinutes = sessions.reduce(0) { sum, session in
            let h = (session.sessionDuration.hour ?? 0) * 60
            let m = (session.sessionDuration.minute ?? 0)
            return sum + h + m
        }
        
        let hours = totalMinutes / 60
        
        return "\(hours)h"
    }
}

struct ProfitByStakesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfitByStakesView(viewModel: SessionsListViewModel())
                .environmentObject(SubscriptionManager())
        }
        .preferredColorScheme(.dark)
    }
}
