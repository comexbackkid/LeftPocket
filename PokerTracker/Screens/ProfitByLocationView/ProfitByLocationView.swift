//
//  ProfitByLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/6/21.
//

import SwiftUI
import RevenueCatUI
import RevenueCat


struct ProfitByLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var yearFilter = Date().getYear()
    @State private var metricFilter = "Total"
    @State private var showPaywall = false
    
    @EnvironmentObject var subManager: SubscriptionManager
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ScrollView {
            ZStack {
                VStack {
                    
                    if viewModel.sessions.isEmpty {
                        
                        EmptyState(title: "No Sessions", image: .locations)
                        
                    } else {
                        
                        VStack { }.frame(height: 40)

                        VStack (spacing: 10) {
                            
                            locationTotals
                            
                            yearTotal
                        }
                                                
                        if subManager.isSubscribed {
                            
                            locationWinRatesChart
                            
                        } else {
                            locationWinRatesChart
                                .blur(radius: 8)
                                .overlay {
                                    Button {
                                        showPaywall = true
                                        
                                    } label: {
                                        Text("🔒 Tap to Upgrade")
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
                .task {
                    for await customerInfo in Purchases.shared.customerInfoStream {
                        showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                        await subManager.checkSubscriptionStatus()
                    }
                }
            }
            .padding(.bottom, 60)
        }
        .toolbar { headerInfo }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Location Statistics"))
        .background(Color.brandBackground)
        .dynamicTypeSize(.xSmall...DynamicTypeSize.large)
    }
    
    var headerInfo: some View {
        
        VStack {
            
            let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
            
            HStack {
                
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
        
//        VStack (spacing: 7) {
//            
//            HStack {
//                Text("Select Year")
//                    
//                
//                Spacer()
//                
//                let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
//                
//                Menu {
//                    Picker("", selection: $yearFilter) {
//                        ForEach(allYears, id: \.self) {
//                            Text($0)
//                        }
//                    }
//                } label: {
//                    Text(yearFilter + " ›")
//                        
//                }
//                .accentColor(Color.brandPrimary)
//                .transaction { transaction in
//                    transaction.animation = nil
//                }
//            }
//            .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
//            
//            HStack {
//                Text("Select Metric")
//                    
//                
//                Spacer()
//                
//                Menu {
//                    Picker("", selection: $metricFilter) {
//                        Text("Total").tag("Total")
//                        Text("Hourly").tag("Hourly")
//                    }
//                } label: {
//                    Text(metricFilter + " ›")
//                        
//                }
//                .accentColor(Color.brandPrimary)
//                .transaction { transaction in
//                    transaction.animation = nil
//                }
//            }
//            .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
//        }
//        .padding(.bottom, 10)
    }
    
    var locationTotals: some View {
        
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
            
            let locationList = viewModel.sessions.map({ $0.location.name }).uniqued()
            
            ForEach(locationList, id: \.self) { location in
                HStack {
                    Text(location)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Still won't grab data if Sessions are imported from a CSV
                    let filteredByYear = viewModel.sessions.filter({ $0.date.getYear() == yearFilter })
                    let total = filteredByYear.filter({ $0.location.name == location }).map({ $0.profit }).reduce(0,+)
                    let hourlyRate = hourlyByLocation(location: location, sessions: filteredByYear)
                    let hoursPlayed = filteredByYear.filter({ $0.location.name == location }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
                    
                    Text(total.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: total)
                        .frame(width: 62, alignment: .trailing)
                    
                    
                    Text(hourlyRate.axisShortHand(viewModel.userCurrency))
                        .profitColor(total: hourlyRate)
                        .frame(width: 62, alignment: .trailing)
                    
                    Text(hoursPlayed.abbreviateHourTotal + "h")
                        .frame(width: 62, alignment: .trailing)
                    
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
            }
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
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
    
    var locationWinRatesChart: some View {
        
        RingCharts(viewModel: viewModel, yearFilter: $yearFilter)
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .padding(.top, 15)
        
    }
    
    private func hourlyByLocation(location: String, sessions: [PokerSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let totalHours = Float(sessions.filter{ $0.location.name == location }.map { $0.sessionDuration.hour ?? 0 }.reduce(0,+))
        let totalMinutes = Float(sessions.filter{ $0.location.name == location }.map { $0.sessionDuration.minute ?? 0 }.reduce(0,+))
        
        // Add up all the hours & minutes together to simply get a sum of hours
        let totalTime = totalHours + (totalMinutes / 60)
        let totalEarnings = sessions.filter({ $0.location.name == location }).map({ Int($0.profit) }).reduce(0,+)
        
        guard totalTime > 0 else { return 0 }
        if totalHours < 1 {
            return Int(Float(totalEarnings) / (totalMinutes / 60))
        } else {
            return Int(Float(totalEarnings) / totalTime)
        }
    }
}

struct ProfitByLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByLocationView(viewModel: SessionsListViewModel())
                .environmentObject(SubscriptionManager())
                .preferredColorScheme(.dark)
        }
    }
}
