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

                                HStack {
                                    dayOfWeekChart
                                    Spacer()
                                    donutChart
                                }
                                
                                performanceChart
                                
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
        .task {
            await subManager.checkTrialStatus()
        }
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
    
    var dayOfWeekChart: some View {
        HStack {
            DayOfWeekChart(sessions: viewModel.allCashSessions())
                .padding(.leading, 7)
                .frame(height: 190)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(12)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        }
        .padding(.trailing, 6)
    }
    
    var donutChart: some View {
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

struct AllStats: View {
    
    @State private var highHandPopover = false
    @Environment(\.colorScheme) var colorScheme
    
    let sessionFilter: SessionFilter
    let viewModel: SessionsListViewModel
    let range: RangeSelection
    let bankroll: BankrollSelection
    
    var body: some View {
        
        VStack {
            
            let currencyType = viewModel.userCurrency.rawValue
            let totalBankroll = viewModel.tallyBankroll(bankroll: bankroll, type: sessionFilter, range: range)
            let hourlyRate = viewModel.hourlyRate(bankroll: bankroll, type: sessionFilter, range: range)
            let profitPerSession = viewModel.avgProfit(bankroll: bankroll, type: sessionFilter, range: range)
            let highHandBonus = viewModel.totalHighHands(bankroll: bankroll, range: range)
            let avgDuration = viewModel.avgDuration(bankroll: bankroll, type: sessionFilter, range: range)
            let totalSessions = viewModel.countSessions(bankroll: bankroll, type: sessionFilter, range: range)
            let totalWinRate = viewModel.totalWinRate(bankroll: bankroll, type: sessionFilter, range: range)
            let totalHours = viewModel.totalHoursPlayed(bankroll: bankroll, type: sessionFilter, range: range)
            let avgROI = viewModel.avgROI(bankroll: bankroll, range: range)
            let handsPlayed = viewModel.handsPlayed(bankroll: bankroll, type: sessionFilter, range: range)
            let profitPer100 = viewModel.profitPer100(hands: handsPlayed, bankroll: totalBankroll)
            
            HStack {
                Text("Total Profit")
                    .foregroundColor(.secondary)
                
                Spacer()
        
                Text(totalBankroll, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: totalBankroll)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Hourly Rate")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(hourlyRate, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: hourlyRate)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Profit Per Session")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(profitPerSession, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: profitPerSession)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Profit Per 100 Hands")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(profitPer100, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: profitPer100)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack (alignment: .lastTextBaseline, spacing: 4) {
                Text("High Hand Bonuses")
                    .foregroundColor(.secondary)
                Button {
                    highHandPopover = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color.brandPrimary)
                }
                .popover(isPresented: $highHandPopover, arrowEdge: .bottom, content: {
                    PopoverView(bodyText: "High hand bonuses are not factored in to your profit or player metrics. You can find them tallied in with your Annual Report.")
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                })
                
                Spacer()
                
                Text(highHandBonus, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: highHandBonus)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Avg. ROI")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(avgROI)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Avg. Duration")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(avgDuration)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Total No. of Sessions")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(totalSessions)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Win Ratio")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(totalWinRate.asPercent())
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Total Hands Dealt")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(handsPlayed)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Total Hours Played")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(totalHours)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
    }
}

struct CashStats: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var highHandPopover = false
    @State private var bbPerHrPopover = false
    
    let sessionFilter: SessionFilter
    let viewModel: SessionsListViewModel
    let range: RangeSelection
    let bankroll: BankrollSelection
    
    var body: some View {
        
        VStack {
            
            let currencyType = viewModel.userCurrency.rawValue
            let cashBankroll = viewModel.tallyBankroll(bankroll: bankroll, type: sessionFilter, range: range)
            let hourlyRate = viewModel.hourlyRate(bankroll: bankroll, type: sessionFilter, range: range)
            let profitPerSession = viewModel.avgProfit(bankroll: bankroll, type: sessionFilter, range: range)
            let highHandBonus = viewModel.totalHighHands(bankroll: bankroll, range: range)
            let avgDuration = viewModel.avgDuration(bankroll: bankroll, type: sessionFilter, range: range)
            let cashWinCount = viewModel.numOfCashes(bankroll: bankroll, range: range)
            let totalSessions = viewModel.countSessions(bankroll: bankroll, type: sessionFilter, range: range)
            let cashWinRate = viewModel.totalWinRate(bankroll: bankroll, type: sessionFilter, range: range)
            let cashTotalHours = viewModel.totalHoursPlayed(bankroll: bankroll, type: sessionFilter, range: range)
            let handsPlayed = viewModel.handsPlayed(bankroll: bankroll, type: sessionFilter, range: range)
            let profitPer100 = viewModel.profitPer100(hands: handsPlayed, bankroll: cashBankroll)
            
            HStack {
                Text("Cash Profit")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(cashBankroll, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: cashBankroll)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Hourly Rate")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(hourlyRate, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: hourlyRate)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Profit Per Session")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(profitPerSession, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: profitPerSession)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Profit Per 100 Hands")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(profitPer100, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: profitPer100)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack (alignment: .lastTextBaseline, spacing: 4) {
                Text("High Hand Bonuses")
                    .foregroundColor(.secondary)
                Button {
                    highHandPopover = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color.brandPrimary)
                }
                .popover(isPresented: $highHandPopover, arrowEdge: .bottom, content: {
                    PopoverView(bodyText: "High hand bonuses are not factored in to your profit or player metrics. You can find them tallied in with your Annual Report.")
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                })
                
                Spacer()
                
                Text(highHandBonus, format: .currency(code: currencyType).precision(.fractionLength(0)))
                    .metricsProfitColor(for: highHandBonus)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
                                    
            }
            
            Divider()
            
            HStack (alignment: .lastTextBaseline, spacing: 4) {
                
                HStack {
                    Text("Avg. BB / Hr")
                        .foregroundColor(.secondary)
                    Button {
                        bbPerHrPopover = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                    .popover(isPresented: $bbPerHrPopover, arrowEdge: .bottom, content: {
                        PopoverView(bodyText: "This number is an average of all your big blind per hour finishes across ALL stakes. For a more detailed breakdown of your BB / Hr rate, scroll down to your Game Stakes Report.")
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                            .presentationCompactAdaptation(.popover)
                            .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                            .shadow(radius: 10)
                            .padding(.horizontal)
                    })
                }
                
                Spacer()
                
                Text("\(viewModel.bbPerHour(range: range), specifier: "%.2f")")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Avg. Duration")
                    .foregroundColor(.secondary)
                Spacer()
                Text(avgDuration)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("No. of Cashes")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(cashWinCount) of \(totalSessions)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Win Ratio")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(cashWinRate.asPercent())
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Hands Dealt")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(handsPlayed)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Hours Played")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(cashTotalHours)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
    }
}

struct TournamentStats: View {
    
    let sessionFilter: SessionFilter
    let viewModel: SessionsListViewModel
    let range: RangeSelection
    let bankroll: BankrollSelection
    
    var body: some View {
        
        VStack {
            
            let tournamentProfit = viewModel.tallyBankroll(bankroll: bankroll, type: .tournaments, range: range)
            let tournamentHourlyRate = viewModel.hourlyRate(bankroll: bankroll, type: .tournaments, range: range)
            let tournamentAvgDuration = viewModel.avgDuration(bankroll: bankroll, type: .tournaments, range: range)
            let avgTournamentBuyIn = viewModel.avgTournamentBuyIn(bankroll: bankroll, range: range)
            let tournamentCount = viewModel.tournamentCount(bankroll: bankroll, range: range)
            let itmRatio = viewModel.inTheMoneyRatio(bankroll: bankroll, range: range)
            let tournamentROI = viewModel.tournamentReturnOnInvestment(bankroll: bankroll, range: range)
            let tournamentHrsPlayed = viewModel.totalHoursPlayed(bankroll: bankroll, type: .tournaments, range: range)
            let handsPlayed = viewModel.handsPlayed(bankroll: bankroll, type: .tournaments, range: range)
            let bounties = viewModel.bountiesCollected(bankroll: bankroll, range: range)
            let actionSold = viewModel.totalActionSold(bankroll: bankroll, range: range)
            
            HStack {
                Text("Tournament Profit")
                    .foregroundColor(.secondary)
                Spacer()
                Text(tournamentProfit, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .metricsProfitColor(for: tournamentProfit)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Hourly Rate")
                    .foregroundColor(.secondary)
                Spacer()
                Text(tournamentHourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .metricsProfitColor(for: tournamentHourlyRate)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Avg. Buy In")
                    .foregroundColor(.secondary)
                Spacer()
                Text(avgTournamentBuyIn, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Bounties Collected")
                    .foregroundColor(.secondary)
                Spacer()
                Text(bounties, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Total Action Sold")
                    .foregroundColor(.secondary)
                Spacer()
                Text(actionSold, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Avg. Duration")
                    .foregroundColor(.secondary)
                Spacer()
                Text(tournamentAvgDuration)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("No. of Tournaments")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(tournamentCount)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
//            Divider()
//            
//            HStack {
//                Text("Avg. No. of Rebuys")
//                    .foregroundColor(.secondary)
//                Spacer()
//                Text("\(avgRebuyCount, specifier: "%.1f")")
//                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
//            }
            
            Divider()
            
            HStack {
                Text("ITM Ratio")
                    .foregroundColor(.secondary)
                Spacer()
                Text(itmRatio)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("ROI")
                    .foregroundColor(.secondary)
                Spacer()
                Text(tournamentROI)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Hands Dealt")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(handsPlayed)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            Divider()
            
            HStack {
                Text("Hours Played")
                    .foregroundColor(.secondary)
                Spacer()
                Text(tournamentHrsPlayed)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .callout))
    }
}

struct ToolTipView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let image: String
    let message: String
    let color: Color
    let premium: Bool?
    
    init(image: String, message: String, color: Color, premium: Bool? = nil) {
        self.image = image
        self.message = message
        self.color = color
        self.premium = premium
    }
    
    var body: some View {
        
        HStack {
            
            Image(systemName: image)
                .foregroundColor(color)
                .font(.system(size: 25, weight: .bold))
                .padding(.trailing, 10)
                .frame(width: 40)
            
            Text(message)
                .calloutStyle()
                .blur(radius: premium == true ? 3 : 0)
            
            Spacer()
            
        }
        .padding(20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

struct PlayerStatsCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: SessionsListViewModel
    @Binding var bankrollFilter: BankrollSelection
    @Binding var sessionFilter: SessionFilter
    @Binding var statsRange: RangeSelection
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Player Stats")
                        .cardTitleStyle()
                    
                    Spacer()

                    Menu {
                        
                        Menu {
                            Picker("Bankroll Picker", selection: $bankrollFilter) {
                                Text("All").tag(BankrollSelection.all)
                                Text("Default").tag(BankrollSelection.default)
                                ForEach(viewModel.bankrolls) { bankroll in
                                    Text(bankroll.name).tag(BankrollSelection.custom(bankroll.id))
                                }
                            }
                            
                        } label: {
                            HStack {
                                Text("Bankrolls")
                                Image(systemName: "bag.fill")
                            }
                        }
                        
                        Picker("Session Filter", selection: $sessionFilter) {
                            ForEach(SessionFilter.allCases, id: \.self) {
                                Text($0.rawValue.capitalized).tag($0)
                            }
                        }
                        
                    } label: {
                        NonAnimatedMenuLabel(text: sessionFilter.rawValue.capitalized + " ›")
                    }
                }
                .padding(.bottom)
                
                switch sessionFilter {
                case .all: AllStats(sessionFilter: sessionFilter, viewModel: viewModel, range: statsRange, bankroll: bankrollFilter)
                case .cash: CashStats(sessionFilter: sessionFilter, viewModel: viewModel, range: statsRange, bankroll: bankrollFilter)
                case .tournaments: TournamentStats(sessionFilter: sessionFilter, viewModel: viewModel, range: statsRange, bankroll: bankrollFilter)
                }
                
                rangeSelector
            }
        }
        .cardStyle(colorScheme: colorScheme)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    var rangeSelector: some View {
        
        HStack (spacing: 10) {
            
            ForEach(RangeSelection.allCases, id: \.self) { range in
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    statsRange = range
                    
                } label: {
                    Text("\(range.displayName)")
                        .bodyStyle()
                        .fontWeight(statsRange == range ? .black : .regular)
                }
                .tint(statsRange == range ? .primary : .brandPrimary)
            }
            
            Spacer()
        }
        .padding(.top, 20)
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

struct AdditionalMetricsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var showPaywall = false
    @AppStorage("showReportsAsList") private var showReportsAsList = false
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            HStack (alignment: .lastTextBaseline) {
                Text("My Reports")
                    .font(.custom("Asap-Black", size: 34))
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                
                HStack (spacing: 0) {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        showReportsAsList.toggle()
                        
                    } label: {
                        Image(systemName: showReportsAsList ? "rectangle" : "list.bullet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.bold)
                            .frame(height: 18)
                            
                    }
                    .tint(.brandPrimary)
                    
                    Text(" ›")
                        .bodyStyle()
                        .foregroundStyle(Color.brandPrimary)
                }
                
                Spacer()
            }
            
            if showReportsAsList {
                VStack (alignment: .leading, spacing: 8) {
                    HStack (spacing: 0) {
                        Text("View your ")
                            .bodyStyle()
                        
                        NavigationLink {
                            ProfitByYear()
                        } label: {
                            Text("__Annual Report__ \(Image(systemName: "arrow.turn.up.right"))")
                                .bodyStyle()
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)

                    HStack(spacing: 0) {
                        Text("View your ")
                            .bodyStyle()
                        
                        NavigationLink {
                            SleepAnalytics(activeSheet: .constant(.none))
                        } label: {
                            Text("__Health Analytics__ \(Image(systemName: "arrow.turn.up.right"))")
                                .bodyStyle()
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)

                    HStack(spacing: 0) {
                        Text("View your ")
                            .bodyStyle()
                        
                        NavigationLink {
                            ProfitByMonth(vm: viewModel)
                        } label: {
                            Text("__Monthly Snapshot__ \(Image(systemName: "arrow.turn.up.right"))")
                                .bodyStyle()
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)

                    HStack(spacing: 0) {
                        Text("View your ")
                            .bodyStyle()
                        
                        NavigationLink {
                            AdvancedTournamentReport(vm: viewModel)
                        } label: {
                            Text("__Tournament Report__ \(Image(systemName: "arrow.turn.up.right"))")
                                .bodyStyle()
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)

                    HStack(spacing: 0) {
                        Text("View your ")
                            .bodyStyle()
                        
                        NavigationLink {
                            ProfitByLocationView(viewModel: viewModel)
                        } label: {
                            Text("__Location Statistics__ \(Image(systemName: "arrow.turn.up.right"))")
                                .bodyStyle()
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)

                    HStack(spacing: 0) {
                        Text("View your ")
                            .bodyStyle()
                        
                        NavigationLink {
                            ProfitByStakesView(viewModel: viewModel)
                        } label: {
                            Text("__Game Stakes__ \(Image(systemName: "arrow.turn.up.right"))")
                                .bodyStyle()
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)

                    HStack(spacing: 0) {
                        Text("View your ")
                            .bodyStyle()
                        
                        NavigationLink {
                            TagReport()
                        } label: {
                            Text("__Tags Report__ \(Image(systemName: "arrow.turn.up.right"))")
                                .bodyStyle()
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 20)
                
            } else {
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack (spacing: 12) {
                        
                        NavigationLink(
                            destination: ProfitByYear(),
                            label: {
                                AdditionalMetricsCardView(title: "Annual Report",
                                                          description: "Year-over-year results",
                                                          image: "list.clipboard.fill",
                                                          color: .donutChartDarkBlue)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: SleepAnalytics(activeSheet: .constant(.none)),
                            label: {
                                AdditionalMetricsCardView(title: "Health Analytics",
                                                          description: "Sleep & mindfulness",
                                                          image: "stethoscope",
                                                          color: .lightGreen)
                                
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByMonth(vm: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Monthly Snapshot",
                                                          description: "Results by month",
                                                          image: "calendar",
                                                          color: .donutChartGreen)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: AdvancedTournamentReport(vm: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Tournaments",
                                                          description: "More tournament stats",
                                                          image: "person.2.fill",
                                                          color: .brandPrimary)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByLocationView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Location Report",
                                                          description: "Stats by location",
                                                          image: "mappin.and.ellipse",
                                                          color: .donutChartRed)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByStakesView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Game Stakes",
                                                          description: "Individual stakes stats",
                                                          image: "dollarsign.circle",
                                                          color: .donutChartPurple)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: TagReport(),
                            label: {
                                AdditionalMetricsCardView(title: "Tag Report",
                                                          description: "Generate report by Tags",
                                                          image: "tag.fill",
                                                          color: colorScheme == .dark ? .brandWhite : .gray)
                            })
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .frame(height: 150)
                })
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
                .scrollBounceBehavior(.automatic)
            }
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
