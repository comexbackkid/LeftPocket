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
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: 20) {
                
                if !hideBankroll { bankrollView }
                
                if viewModel.sessions.isEmpty {
                    
                    emptyState
                    
                } else {
                    
                    quickMetricsBoxes
                                        
                    metricsCard
                    
                    recentSessionCard
                    
                    healthAnalyticsCard

                    Spacer()
                }
            }
            .padding(.horizontal, isPad ? 40 : 16)
            .padding(.bottom, 50)
        }
        .background { Color.brandBackground.ignoresSafeArea() }
        .sheet(item: $activeSheet) { sheet in
            let recentSession = (viewModel.sessions + viewModel.bankrolls.flatMap(\.sessions)).sorted(by: { $0.date > $1.date }).first!
            switch sheet {
            case .productUpdates: ProductUpdates(activeSheet: $activeSheet)
            case .recentSession: if isPad {
                if #available(iOS 18.0, *) {
                    SessionDetailView(activeSheet: $activeSheet, pokerSession: viewModel.sessions.first!)
                        .presentationSizing(.page)
                } else {
                    SessionDetailView(activeSheet: $activeSheet, pokerSession: viewModel.sessions.first!)
                }
            } else {
                SessionDetailView(activeSheet: $activeSheet, pokerSession: recentSession)
                    .presentationDragIndicator(.visible)
            }
            case .healthAnalytics: SleepAnalytics(activeSheet: $activeSheet).dynamicTypeSize(...DynamicTypeSize.xLarge)
            case .metricsAsSheet: if isPad {
                if #available(iOS 18.0, *) {
                    MetricsView(activeSheet: $activeSheet).dynamicTypeSize(...DynamicTypeSize.xLarge)
                        .presentationSizing(.page)
                } else {
                    MetricsView(activeSheet: $activeSheet).dynamicTypeSize(...DynamicTypeSize.xLarge)
                }
            } else { MetricsView(activeSheet: $activeSheet).dynamicTypeSize(...DynamicTypeSize.xLarge) }
            }
        }
    }
    
    var bankroll: Int {
        let legacyHighHands = viewModel.sessions.map(\.highHandBonus).reduce(0, +)
        let legacyTransactions = viewModel.transactions.reduce(0) { total, tx in
            switch tx.type {
            case .deposit: return total + tx.amount
            case .withdrawal, .expense: return total - tx.amount
            }
        }
        let legacyProfit = viewModel.sessions.map(\.profit).reduce(0, +)
        
        let customBankrollTotals = viewModel.bankrolls.reduce(0) { total, bankroll in
            let profits = bankroll.sessions.map(\.profit).reduce(0, +)
            let highHands = bankroll.sessions.map(\.highHandBonus).reduce(0, +)
            let txTotal = bankroll.transactions.reduce(0) { subTotal, tx in
                switch tx.type {
                case .deposit: return subTotal + tx.amount
                case .withdrawal, .expense: return subTotal - tx.amount
                }
            }
            return total + profits + txTotal + highHands
        }
        
        return legacyProfit + legacyTransactions + legacyHighHands + customBankrollTotals
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
            
            Text("Tap the \(Image(systemName: "cross.fill")) button below to get started.\nDuring a Live Session, add rebuys by\npressing the \(Image(systemName: "dollarsign.arrow.circlepath")) button.")
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
        
        VStack {
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
            
            Spacer()
        }
    }
    
    var quickMetricsBoxes: some View {
        
        QuickMetricsBoxGrid(viewModel: viewModel)
            .padding(.top, hideBankroll ? 30 : 0)
    }
    
    var metricsCard: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            activeSheet = .metricsAsSheet
            
        } label: {
            if !hideBankroll {
                MetricsCardView()
                
            } else { metricsMiniCard }
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(1.0)
    }
    
    var metricsMiniCard: some View {
        
        VStack {
            
            HStack {
                BankrollLineChart(minimizeLineChart: .constant(false), showTitle: false, showYAxis: false, showRangeSelector: false, showPatternBackground: false, overlayAnnotation: false, showToggleAndFilter: false)
                    .frame(width: 80, height: 50)
                
                VStack (alignment: .leading, spacing: 5) {
                    
                    Text("Bankroll & Metrics")
                        .headlineStyle()
                    
                    Text("Tap to view your bankroll progress, player metrics, analytics, & reports.")
                        .font(.custom("Asap-Regular", size: 14))
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
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.5 : 1.0))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    var recentSessionCard: some View {
        
        Group {
            let recentSession = (viewModel.sessions + viewModel.bankrolls.flatMap(\.sessions)).sorted(by: { $0.date > $1.date }).first!
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                activeSheet = .recentSession
                
            }, label: {
                RecentSessionCardView(pokerSession: recentSession)
            })
            .buttonStyle(CardViewButtonStyle())
        }
    }
    
    var healthAnalyticsCard: some View {
        
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            activeSheet = .healthAnalytics
        
        }, label: {
            SleepCardView()
        })
        .buttonStyle(CardViewButtonStyle())
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
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                            .presentationCompactAdaptation(.popover)
                            .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                            .shadow(radius: 10)
                            .padding(.horizontal)
                    })
                }
                
                Text(bankroll, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Bold", size: 60, relativeTo: .title2))
                    .opacity(0.85)
                
                if !viewModel.sessions.isEmpty {
                    HStack {
                        
                        Image(systemName: "arrow.up.right")
                            .resizable()
                            .frame(width: 13, height: 13)
                            .fontWeight(.bold)
                            .metricsProfitColor(for: lastSession)
                            .rotationEffect(lastSession >= 0 ? .degrees(0) : .degrees(90))
                        
                        Text(lastSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                            .fontWeight(.bold)
                            .metricsProfitColor(for: lastSession)
                    }
                    .offset(y: -32)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
        .padding(.top, 20)
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

struct QuickMetricsBoxGrid: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    @State private var playerProfit: Bool = false
    @State private var bbPerHr: Bool = false
    @State private var hourlyRate: Bool = false
    @State private var profitPerSession: Bool = false
    @State private var winRatio: Bool = false
    @State private var hoursPlayed: Bool = false
    
    private let columns = [GridItem(spacing: 10), GridItem()]
    
    var body: some View {
        
        // Stuck trying to figure out how to get a starting number, looking messy this way
        // Right now I think the previous year calculation is ONLY sessions that happened in that year, not the year's end value cumulatively
        LazyVGrid(columns: columns, spacing: 20) {
            let playerProfitNumber = viewModel.tallyBankroll(type: .all).dashboardPlayerProfitShortHand(viewModel.userCurrency)
            let bbPerHrNumber = viewModel.bbPerHour()
            let hourlyRateNumber = viewModel.hourlyRate(type: .all).currencyShortHand(viewModel.userCurrency)
            let profitPerSessionNumber = viewModel.avgProfit(type: .all).currencyShortHand(viewModel.userCurrency)
            let winRatioNumber = viewModel.totalWinRate(type: .all)
            let hoursPlayedNumber = viewModel.totalHoursPlayedHomeScreen()
            
            if playerProfit {
                QuickMetricBox(title: "Total Profit",
                               metric: playerProfitNumber,
                               percentageChange: percentChange(Double(viewModel.tallyBankroll(type: .all)),
                                                               Double(viewModel.tallyBankroll(type: .all, excludingYear: Date().getYear()))))
            }
            
            if bbPerHr {
                QuickMetricBox(title: "BB / Hr",
                               metric: String(format: "%.2f", bbPerHrNumber),
                               percentageChange: percentChange(bbPerHrNumber,
                                                               viewModel.bbPerHour(excludingYear: Date().getYear())))
            }
            
            if hourlyRate {
                QuickMetricBox(title: "Hourly Rate",
                               metric: hourlyRateNumber,
                               percentageChange: percentChange(Double(viewModel.hourlyRate(type: .all)),
                                                               Double(viewModel.hourlyRate(type: .all, excludingYear: Date().getYear()))))
            }
            
            if profitPerSession {
                QuickMetricBox(title: "Avg. Session Profit",
                               metric: profitPerSessionNumber,
                               percentageChange: percentChange(Double(viewModel.avgProfit(type: .all)),
                                                               Double(viewModel.avgProfit(type: .all, excludingYear: Date().getYear()))))
            }
            
            if winRatio {
                QuickMetricBox(title: "Win Ratio",
                               metric: winRatioNumber.asPercent(),
                               percentageChange: percentChange(winRatioNumber,
                                                               viewModel.totalWinRate(type: .all, excludingYear: Date().getYear())))
            }
            
            if hoursPlayed {
                QuickMetricBox(title: "Hours Played",
                               metric: hoursPlayedNumber,
                               percentageChange: 0)
            }
        }
        .onAppear { loadDashboardConfig() }
    }
    
    private func loadDashboardConfig() {
        
        let defaults = UserDefaults.standard
        
        // Use the default value of true for "PlayerProfit" and "HoursPlayed" if none found in UserDefaults
        if defaults.object(forKey: "dashboardPlayerProfit") == nil {
            self.playerProfit = true
        } else {
            self.playerProfit = defaults.bool(forKey: "dashboardPlayerProfit")
        }
        
        self.bbPerHr = defaults.bool(forKey: "dashboardBbPerHr")
        self.hourlyRate = defaults.bool(forKey: "dashboardHourlyRate")
        self.profitPerSession = defaults.bool(forKey: "dashboardProfitPerSession")
        self.winRatio = defaults.bool(forKey: "dashboardWinRatio")
        
        // Use the default value of true for "HoursPlayed" if not found in UserDefaults
        if defaults.object(forKey: "dashboardHoursPlayed") == nil {
            self.hoursPlayed = true
        } else {
            self.hoursPlayed = defaults.bool(forKey: "dashboardHoursPlayed")
        }
    }
    
    private func percentChange(_ newValue: Double, _ oldValue: Double) -> Double {
        guard oldValue != 0 else { return newValue.isZero ? 0 : .infinity }
        let percentage = ((newValue - oldValue) / abs(oldValue))
        return percentage
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
    
    case productUpdates, recentSession, healthAnalytics, metricsAsSheet
    
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
