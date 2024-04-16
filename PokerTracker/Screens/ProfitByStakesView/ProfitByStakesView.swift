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
                VStack {
                    
                    VStack (spacing: 10) {
                        
                        headerInfo
                        
                        Divider()
                            .padding(.bottom, 10)
                        
                        stakesTotals
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle(Text("Game Stakes"))
                    .padding(30)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
                    .cornerRadius(20)
                    .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                    .padding(.top, 50)
                    
                    yearTotal
                    
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
                                }
                            }
                    }
                   
                    HStack {
                        Spacer()
                    }
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                }
                .task {
                    for await customerInfo in Purchases.shared.customerInfoStream {
                        showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                        await subManager.checkSubscriptionStatus()
                    }
                }
                
                if viewModel.sessions.filter({ $0.isTournament == false }).isEmpty {
                    EmptyState(image: .sessions)
                }
            }
            .padding(.bottom, 60)
        }
        .background(Color.brandBackground)
    }
    
    var headerInfo: some View {
        
        VStack (spacing: 7) {
            
            HStack {
                Text("Select Year")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
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
            
            HStack {
                Text("Select Metric")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Menu {
                    Picker("", selection: $metricFilter) {
                        Text("Total").tag("Total")
                        Text("Hourly").tag("Hourly")
                    }
                } label: {
                    Text(metricFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
        }
        .padding(.bottom, 10)
    }
    
    var stakesTotals: some View {
        
        ForEach(viewModel.uniqueStakes, id: \.self) { stakes in
            
            HStack {
                Text(stakes)
                    .font(.custom("Asap-Regular", size: 18, relativeTo: .body))

                Spacer()

                let total = viewModel.profitByStakes(stakes, year: yearFilter)
                let hourlyRate = viewModel.hourlyByStakes(stakes: stakes, total: total)
                
                if metricFilter == "Total" {
                    Text(total, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                        .profitColor(total: total)
                        .frame(width: 80, alignment: .trailing)
                } else {
                    Text("\(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))) / hr")
                        .profitColor(total: hourlyRate)
                        .frame(width: 80, alignment: .trailing)
                }
            }
            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        }
    }
    
    var yearTotal: some View {
        
        VStack (spacing: 7) {
            
            let bankrollTotalByYear = viewModel.bankrollByYear(year: yearFilter)
            
            HStack {
                Image(systemName: "trophy.fill")
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
                    .bodyStyle()
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        .padding(.top, 15)
    }
    
    var stakesChart: some View {
        
        BarChartByStakes(viewModel: viewModel, yearFilter: $yearFilter ,showTitle: true)
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
            .padding(.top, 15)
            .frame(height: 275)
    }
}

struct ProfitByStakesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByStakesView(viewModel: SessionsListViewModel())
                .environmentObject(SubscriptionManager())
                .preferredColorScheme(.dark)
        }
    }
}
