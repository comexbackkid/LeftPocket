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
    
    @State private var yearFilter = Date().getYear()
    @State private var metricFilter = "Total"
    @State private var showPaywall = false
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ScrollView {

            ZStack {
                
                // Must use this for empty state just in case the user only plays Tournments
                if !viewModel.sessions.filter({ $0.isTournament != true }).isEmpty {

                    VStack {
                        
                        VStack (spacing: 10) {
                            
                            stakesTotals
                            
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle(Text("Game Stakes"))
                        .padding(20)
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
                        .cornerRadius(20)
                        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
                        .padding(.top, 50)
                        
                        yearTotal
                        
                        let bestStakes = ueserBestStakes(sessions: viewModel.sessions.filter({ $0.date.getYear() == yearFilter }))
                        
                        ToolTipView(image: "dollarsign.circle", message: "Based on your hourly rates, your best game stakes are \(bestStakes).", color: Color.donutChartPurple)
                            .padding(.top)
                        
                        if subManager.isSubscribed {
                            stakesChart
                            
                        } else {
                            stakesChart
                                .blur(radius: 8)
                                .overlay {
                                    Button {
                                        showPaywall = true
                                        
                                    } label: {
                                        Text("Upgrade for Access")
                                            .buttonTextStyle()
                                            .frame(height: 55)
                                            .frame(width: UIScreen.main.bounds.width * 0.7)
                                            .background(Color.brandPrimary)
                                            .foregroundColor(.white)
                                            .cornerRadius(30)
                                            .shadow(radius: 10)
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
                    .toolbar {
                        headerInfo
                    }
                    .task {
                        for await customerInfo in Purchases.shared.customerInfoStream {
                            showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                            await subManager.checkSubscriptionStatus()
                        }
                    }
                } else {
                    VStack {
                        EmptyState(title: "No Sessions", image: .sessions)
                    }
                    
                }
                
            }
            .dynamicTypeSize(.xSmall...DynamicTypeSize.large)
            .padding(.bottom, 60)
        }
        .background(Color.brandBackground)
    }
    
    var headerInfo: some View {
        
        VStack {
            
            HStack {
                
                let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
                
                Menu {
                    Picker("", selection: $yearFilter) {
                        ForEach(allYears, id: \.self) {
                            Text($0)
                        }
                    }
                } label: {
                    Text(yearFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
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
                    
                    let filteredByYear = viewModel.sessions.filter({ $0.date.getYear() == yearFilter })
                    let total = viewModel.profitByStakes(stakes, year: yearFilter)
                    let hourlyRate = hourlyByStakes(stakes: stakes, sessions: filteredByYear)
                    let hoursPlayed = filteredByYear.filter({ $0.stakes == stakes }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
                    let bbPerHr = bbPerHourByStakes(stakes: stakes, sessions: filteredByYear.filter({ $0.stakes == stakes }))
                    
                    Text(total.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: total)
                        .frame(width: 57, alignment: .trailing)
                    
                    Text(hourlyRate.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: hourlyRate)
                        .frame(width: 57, alignment: .trailing)
                    
                    Text("\(bbPerHr, format: .number.precision(.fractionLength(2)))")
                        .frame(width: 57, alignment: .trailing)
                    
                    Text(hoursPlayed.abbreviateHourTotal + "h")
                        .frame(width: 57, alignment: .trailing)
                    
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
            }
        }
    }
    
    var yearTotal: some View {
        
        VStack (spacing: 7) {
            
            let bankrollTotalByYear = viewModel.bankrollByYear(year: yearFilter, sessionFilter: .all)
            
            HStack {
                Image(systemName: "dollarsign")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Total")
                
                Spacer()
                
                Text(bankrollTotalByYear, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bankrollTotalByYear)
            }
            
            HStack {
                Image(systemName: "suit.club.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Sessions")
                
                Spacer()
                
                Text("\(viewModel.sessions.filter({ $0.date.getYear() == yearFilter }).count)")
            }
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top, 15)
    }
    
    var stakesChart: some View {
        
        BarChartByStakes(viewModel: viewModel, yearFilter: $yearFilter ,showTitle: true)
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .padding(.top, 15)
            .frame(height: 275)
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
