//
//  ContentView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("hideBankroll") var hideBankroll: Bool = false
    
    @State private var showMetricsAsSheet = false
    @State private var showSleepAnalyticsAsSheet = false
    @State private var showPaywall = false
    @State private var showBankrollPopup = false
    @State var activeSheet: Sheet?
    
    let lastSeenVersionKey = "LastSeenAppVersion"
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: 20) {
                
                if !hideBankroll { bankrollView }
                
                if viewModel.sessions.isEmpty {
                    
                    emptyState
                    
                } else {
                    
                    HStack {
                        
                        QuickMetricBox(title: "Total Profit", metric: String(viewModel.tallyBankroll(bankroll: .all).currencyShortHand(viewModel.userCurrency)))
                        
                        Spacer()
                        
                        QuickMetricBox(title: "Hours Played", metric: viewModel.totalHoursPlayedHomeScreen())
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .padding(.top, hideBankroll ? 30 : 0)
                                        
                    metricsCard
                    
                    recentSessionCard
                    
                    sleepAnalyticsCard

                    Spacer()
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .padding(.bottom, 50)
        }
        .background { Color.brandBackground.ignoresSafeArea() }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .productUpdates: ProductUpdates(activeSheet: $activeSheet)
            case .recentSession: SessionDetailView(activeSheet: $activeSheet, pokerSession: viewModel.sessions.first!)
            case .sleepAnalytics: SleepAnalytics(activeSheet: $activeSheet)
            case .metricsAsSheet: MetricsView(activeSheet: $activeSheet)
            }
        }
        
    }
    
    var bankroll: Int {
        return viewModel.tallyBankroll(bankroll: .all) + viewModel.transactions.map({ $0.amount }).reduce(0, +)
    }
    
    var emptyState: some View {
        
        VStack (spacing: 5) {
            
            Image("pokerchipsvector-transparent")
                .resizable()
                .frame(width: 125, height: 125)
            
            Text("No Sessions")
                .cardTitleStyle()
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Tap the \(Image(systemName: "plus")) button below to get started.\nDuring a Live Session, add rebuys by\npressing the \(Image(systemName: "dollarsign.arrow.circlepath")) button.")
                .foregroundColor(.secondary)
                .subHeadlineStyle()
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            
            Image("squigleArrow")
                .resizable()
                .frame(width: 80, height: 150)
                .padding(.top, 20)
        }
        
    }
    
    var lastSession: Int {
        return viewModel.sessions.first?.profit ?? 0
    }
    
    var productUpdatesIcon: some View {
        
        HStack {
            Button {
                activeSheet = .productUpdates
            } label: {
                Image(systemName: "bell.fill")
                    .opacity(0.75)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.bottom, -20)
    }
    
    var metricsCard: some View {
        
        Button(action: {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            activeSheet = .metricsAsSheet
            
        }, label: {
            if !hideBankroll {
                MetricsCardView()
                
            } else { metricsMiniCard }
        })
        .buttonStyle(PlainButtonStyle())
        .zIndex(1.0)
    }
    
    var metricsMiniCard: some View {
        
        VStack {
            
            HStack {
                BankrollLineChart(showTitle: false, showYAxis: false, showRangeSelector: false, overlayAnnotation: false)
                    .frame(width: 80, height: 50)
                
                VStack (alignment: .leading, spacing: 5) {
                    
                    Text("Bankroll & Metrics")
                        .headlineStyle()
                    
                    Text("Tap to view your bankroll progress, player metrics, analytics, & reports.")
                        .calloutStyle()
                        .opacity(0.7)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                .padding(.leading, 12)
                .dynamicTypeSize(...DynamicTypeSize.large)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .frame(width: UIScreen.main.bounds.width * 0.85)
    }
    
    var recentSessionCard: some View {
        
        Button(action: {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            activeSheet = .recentSession
            
        }, label: {
            
            RecentSessionCardView(pokerSession: viewModel.sessions.first!)
            
        })
        .buttonStyle(CardViewButtonStyle())
    }
    
    var sleepAnalyticsCard: some View {
        
        Button(action: {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            if subManager.isSubscribed {
                activeSheet = .sleepAnalytics
            } else {
                showPaywall = true
            }
        
        }, label: {
            
            SleepCardView()
        })
        .buttonStyle(CardViewButtonStyle())
        .sheet(isPresented: $showPaywall, content: {
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
        })
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }
    
    var bankrollView: some View {
        
        HStack {
            
            VStack {
                
                HStack (spacing: 5) {
                    Text("My Bankroll")
                        .font(.custom("Asap-Regular", size: 13))
                        .opacity(0.5)
                    
                    Button {
                        showBankrollPopup = true

                    } label: {
                        Image(systemName: "info.circle")
                            .font(.custom("Asap-Regular", size: 13))
                        
                    }
                    .foregroundStyle(Color.brandPrimary)
                    .popover(isPresented: $showBankrollPopup, arrowEdge: .top, content: {
                        PopoverView(bodyText: "\"My Bankroll\" is your true bankroll ledger, including all transactions. \"Total Profit\" represents your poker winnings over time.")
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                            .frame(height: 150)
                            .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                            .presentationCompactAdaptation(.popover)
                            .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                            .shadow(radius: 10)
                    })
                }
                
                Text(bankroll, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Bold", size: 60, relativeTo: .title2))
                    .opacity(0.85)
                    .blur(radius: hideBankroll ? 20 : 0)
                
                if !viewModel.sessions.isEmpty {
                    
                    HStack {
                        
                        Image(systemName: "arrow.up.right")
                            .resizable()
                            .frame(width: 13, height: 13)
                            .fontWeight(.bold)
                            .foregroundColor(lastSession > 0 ? .green : lastSession < 0 ? .red : Color(.systemGray))
                            .rotationEffect(lastSession >= 0 ? .degrees(0) : .degrees(90))
                        
                        Text(lastSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                            .fontWeight(.bold)
                            .profitColor(total: lastSession)
                        
                    }
                    .offset(y: -32)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 25)
    }
    
    func checkForUpdate() {
        let currentVersion = Bundle.main.appVersion
        let lastSeenVersion = UserDefaults.standard.string(forKey: lastSeenVersionKey) ?? "0.0"
        
        // Assuming major updates are determined by the first digit (e.g., 3.4.6 to 4.0)
        if isMajorUpdate(from: lastSeenVersion, to: currentVersion) {
            activeSheet = .productUpdates
        }
        
        // Update the stored version to the current version
        UserDefaults.standard.set(currentVersion, forKey: lastSeenVersionKey)
    }
    
    func isMajorUpdate(from oldVersion: String, to newVersion: String) -> Bool {
            let oldComponents = oldVersion.split(separator: ".")
            let newComponents = newVersion.split(separator: ".")
            
            guard oldComponents.count > 0, newComponents.count > 0 else {
                return false
            }
            
            return oldComponents[0] != newComponents[0]
        }
}

extension SessionsListViewModel {

    func totalHoursPlayedHomeScreen() -> String {
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

enum Sheet: String, Identifiable {
    
    case productUpdates, recentSession, sleepAnalytics, metricsAsSheet
    
    var id: String {
        rawValue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
    }
}
