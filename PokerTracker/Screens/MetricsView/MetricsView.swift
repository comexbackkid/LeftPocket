//
//  MetricsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import TipKit
import RevenueCat
import RevenueCatUI

struct MetricsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var showPaywall = false
    @State private var progressIndicator: Float = 0.0
    @State private var minimizeLineChart = false
    @AppStorage("dateRangeSelection") private var statsRange: RangeSelection = .all
    @AppStorage("sessionFilter") private var sessionFilter: SessionFilter = .all
    @State private var bankrollFilter: BankrollSelection = .default
    @Binding var activeSheet: Sheet?
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                VStack {
                    
                    if !viewModel.allSessions.isEmpty {
                        
                        ScrollView {
                            
                            title
                            
                            VStack (spacing: 22) {
                                
                                winStreakToolTip
                                                                
                                bankrollChart
                                
                                playerStats
                                
                                bankrollProgressView
                                
                                barChart
                                
                                sessionLengthToolTip

                                donutChartWeekdayChart
                                
                                performanceChart
                                
                                weeklySessionCountChart
                            }
                            .padding(.horizontal, isPad ? 40 : 16)
                            .padding(.bottom, 20)
                            
                            AdditionalMetricsView()
                                .padding(.bottom, activeSheet == .metricsAsSheet ? 0 : 50)
                        }
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
                        
                    } else {
                        EmptyState(title: "No Sessions", image: .metrics)
                            .padding(.bottom, 50)
                    }
                }
                .frame(maxHeight: .infinity)
                .background(Color.brandBackground)
                .navigationBarHidden(true)
                
                if activeSheet == .metricsAsSheet { dismissButton }
            }
        }
        .accentColor(.brandPrimary)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Metrics")
                .titleStyle()
                .padding(.top, activeSheet == .metricsAsSheet ? 30 : 0)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var winStreakToolTip: some View {
        
        Group {
            if viewModel.allSessions.count > 1 && viewModel.winStreak() > 2 {
                ToolTipView(image: "flame.fill",
                            message: "You're on a win streak! That's \(viewModel.winStreak()) in a row, well done.",
                            color: .yellow)
                
            } else if viewModel.allSessions.count > 1 && viewModel.winStreak() < -2 {
                ToolTipView(image: "snowflake",
                            message: "You're on a slight downswing. Take a breather, and re-focus.",
                            color: .lightBlue)
                
            } else {
                ToolTipView(image: "lightbulb",
                            message: "Track your performance from here. Tap and hold charts for more info.",
                            color: .yellow)
            }
        }
    }
    
    var sessionLengthToolTip: some View {
        
        Group {
            if !subManager.isSubscribed {
                ToolTipView(image: "stopwatch",
                            message: "You tend to play better when your Session lasts \(viewModel.bestSessionLength()).",
                            color: .brandPrimary,
                            premium: subManager.isSubscribed ? false : true)
                .overlay {
                    if !subManager.isSubscribed {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Upgrade to Pro")
                                .calloutStyle()
                                .fontWeight(.black)
                        }
                        .padding(35)
                        .background(colorScheme == .dark ? Color.black.blur(radius: 25) : Color.white.blur(radius: 25))
                        .onTapGesture {
                            showPaywall = true
                        }
                    }
                }
                .clipped()
                
            } else {
                ToolTipView(image: "stopwatch",
                            message: "You tend to play better when your Session lasts \(viewModel.bestSessionLength())",
                            color: .brandPrimary,
                            premium: subManager.isSubscribed ? false : true)
            }
        }
    }
    
    var bankrollChart: some View {
        BankrollLineChart(minimizeLineChart: $minimizeLineChart, showTitle: true, showYAxis: true, showRangeSelector: true, showPatternBackground: false, overlayAnnotation: false, showToggleAndFilter: true)
            .padding(.bottom, 5)
            .cardStyle(colorScheme: colorScheme, height: minimizeLineChart ? 250 : 475)
            .cardShadow(colorScheme: colorScheme)
    }
    
    var bankrollProgressView: some View {
        
        Group {
            if !subManager.isSubscribed {
                BankrollProgressView(progressIndicator: $progressIndicator, isSubscribed: subManager.isSubscribed)
                    .cardShadow(colorScheme: colorScheme)
                    .overlay {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Upgrade to Pro")
                                .calloutStyle()
                                .fontWeight(.black)
                        }
                        .padding(35)
                        .background(colorScheme == .dark ? Color.black.blur(radius: 25) : Color.white.blur(radius: 25))
                        .onTapGesture {
                            showPaywall = true
                        }
                        
                    }
                    .clipped()
                
            } else {
                BankrollProgressView(progressIndicator: $progressIndicator, isSubscribed: subManager.isSubscribed)
                    .onAppear(perform: {
                        viewModel.updateBankrollProgressRing()
                        self.progressIndicator = viewModel.bankrollProgressRing
                    })
                    .onReceive(viewModel.$progressRingTrigger) { _ in
                        self.progressIndicator = viewModel.bankrollProgressRing
                    }
                    .cardShadow(colorScheme: colorScheme)
            }
        }
    }
    
    var barChart: some View {
        BarChartByYear(showTitle: true, moreAxisMarks: true)
            .cardStyle(colorScheme: colorScheme, height: 380)
            .cardShadow(colorScheme: colorScheme)
    }
    
    var performanceChart: some View {
        PerformanceLineChart()
            .cardStyle(colorScheme: colorScheme, height: 380)
            .cardShadow(colorScheme: colorScheme)
    }
    
    var donutChartWeekdayChart: some View {
        
        HStack {
            
            HStack {
                DayOfWeekChart(sessions: viewModel.allCashSessions())
                    .padding(.leading, 7)
                    .frame(height: 190)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)
                    .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            }
            .padding(.trailing, 6)
            
            Spacer()
            
            HStack {
                BestTimeOfDay()
                    .padding()
                    .frame(height: 190)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)
                    .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            }
            .padding(.leading, 6)
            
        }
    }
    
    var weeklySessionCountChart: some View {
        
        Group {

            let barChartDateRange = viewModel.allSessions.filter({ $0.date.getYear() == Date().getYear() })
            BarChartWeeklySessionCount(showTitle: true, dateRange: barChartDateRange)
                .padding(20)
                .frame(height: 190)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(12)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
                .overlay {
                    if barChartDateRange.isEmpty {
                        VStack {
                            Text("No chart data to display.")
                                .calloutStyle()
                                .foregroundStyle(.secondary)
                        }
                        .offset(y: 20)
                    }
                }
        }
    }
    
    var dismissButton: some View {
        
        VStack {
            HStack {
                Spacer()
                DismissButton()
                    .shadow(color: Color.black.opacity(0.1), radius: 8)
                    .onTapGesture {
                        activeSheet = nil
                    }
            }
            Spacer()
        }
        .padding()
    }
    
    var playerStats: some View {
        PlayerStatsCard(viewModel: viewModel, bankrollFilter: $bankrollFilter, sessionFilter: $sessionFilter, statsRange: $statsRange)
    }
}

struct NonAnimatedMenuLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .bodyStyle()
            .fixedSize(horizontal: true, vertical: false)
            .transaction { transaction in
                transaction.animation = nil
            }
    }
}

struct MetricsView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetricsView(activeSheet: .constant(nil))
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
    }
}
