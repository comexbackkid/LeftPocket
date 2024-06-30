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
    
    @State private var showMetricsAsSheet = false
    @State private var showSleepAnalyticsAsSheet = false
    @State private var showPaywall = false
    @State var activeSheet: Sheet?
    
    let lastSeenVersionKey = "LastSeenAppVersion"
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: 5) {
                
                bankrollView
                
                if viewModel.sessions.isEmpty {
                    
                    emptyState
                    
                } else {
                    
//                    quickMetrics
                    
                    HStack {
                        QuickMetricBox(title: "Session Count", metric: viewModel.sessions.count)
                        Spacer()
                        QuickMetricBox(title: "Total Hours", metric: viewModel.totalHoursPlayedAsInt())
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    
                    metricsCard
                    
                    recentSessionCard
                    
                    sleepAnalyticsCard

                    Spacer()
                }
            }
            .padding(.bottom, 50)
        }
        .background { Color.brandBackground.ignoresSafeArea() }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .productUpdates: ProductUpdates(activeSheet: $activeSheet)
            case .recentSession: SessionDetailView(activeSheet: $activeSheet, pokerSession: viewModel.sessions.first ?? MockData.sampleSession)
            case .sleepAnalytics: SleepAnalytics(activeSheet: $activeSheet)
            case .metricsAsSheet: MetricsView(activeSheet: $activeSheet)
            }
        }
    }
    
    var bankroll: Int {
        return viewModel.tallyBankroll(bankroll: .all)
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
    
    var quickMetrics: some View {
        
        HStack (spacing: 18) {
            
            VStack (spacing: 3) {
                Text(String(viewModel.sessions.count))
                    .font(.system(size: 20, design: .rounded))
                    .opacity(0.75)
                
                Text(viewModel.sessions.count == 1 ? "Session" : "Sessions")
                    .captionStyle()
                    .fontWeight(.thin)
            }
            
            Divider()
            
            VStack (spacing: 3) {
                Text(String(viewModel.totalWinRate(bankroll: .all)))
                    .font(.system(size: 20, design: .rounded))
                    .opacity(0.75)
                
                Text("Win Ratio")
                    .captionStyle()
                    .fontWeight(.thin)
            }
            
            Divider()
            
            VStack (spacing: 3) {
                Text(viewModel.totalHoursPlayedHomeScreen())
                    .font(.system(size: 20, design: .rounded))
                    .opacity(0.75)
                
                Text("Hours")
                    .captionStyle()
                    .fontWeight(.thin)
            }
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.85)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .padding(.bottom, 25)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.23),
                radius: 12, x: 0, y: 5)
        
    }
    
    var metricsCard: some View {
        
        Button(action: {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            activeSheet = .metricsAsSheet
            
        }, label: {
            MetricsCardView()
                .padding(.bottom)
        })
        .padding(.bottom, 12)
        .buttonStyle(PlainButtonStyle())
        .zIndex(1.0)
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
        .padding(.bottom, 30)
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
        .padding(.bottom, 30)
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
                
                Text("My Bankroll")
                    .font(.custom("Asap-Regular", size: 13))
                    .opacity(0.5)
                
                Text(bankroll, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Bold", size: 62, relativeTo: .title2))
                    .opacity(0.85)
                
                if !viewModel.sessions.isEmpty {
                    
                    HStack {
                        
                        Image(systemName: "arrow.up.right")
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundColor(lastSession > 0 ? .green : lastSession < 0 ? .red : Color(.systemGray))
                            .rotationEffect(lastSession >= 0 ? .degrees(0) : .degrees(90))
                        
                        Text(lastSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                            .profitColor(total: lastSession)
                        
                        
                    }
                    .padding(.top, -30)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.bottom, 25)
    }
    
    var homeBackgroundGradient: some View {
        
        RadialGradient(colors: [.brandBackground, Color("newWhite").opacity(0.3)],
                       center: .topLeading,
                       startRadius: 500,
                       endRadius: 5)
        
    }
    
    // These functions here for now if we want it. Don't want to bombard them with sheets and popups.
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
