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
    @AppStorage("dateRangeSelection") private var statsRange: RangeSelection = .all
    @AppStorage("sessionFilter") private var sessionFilter: SessionFilter = .all
    @Binding var activeSheet: Sheet?
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack {
                    
                    if !viewModel.sessions.isEmpty {
                        
                        ScrollView {
                            
                            VStack (spacing: 22) {
                                
                                title
                                
                                winStreakToolTip
                                                                
                                bankrollChart
                                
                                bankrollProgressView
                                
                                playerStats
                                
                                ToolTipView(image: "calendar",
                                            message: "Your best month so far this year has been \(viewModel.bestMonth).",
                                            color: .donutChartOrange)
                                
                                barChart
                                
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

                                HStack {
                                    dayOfWeekChart
                                    Spacer()
                                    donutChart
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                
                                performanceChart
                                
                                AdditionalMetricsView()
                                    .padding(.bottom, activeSheet == .metricsAsSheet ? 0 : 50)
                            }
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
            if viewModel.sessions.count > 1 && viewModel.winStreak() > 2 {
                ToolTipView(image: "flame.fill",
                            message: "You're on a win streak! That's \(viewModel.winStreak()) in a row, well done.",
                            color: .yellow)
                
            } else if viewModel.sessions.count > 1 && viewModel.winStreak() < -2 {
                ToolTipView(image: "snowflake",
                            message: "You're on a slight downswing. Take a breather, & re-focus.",
                            color: .lightBlue)
                
            } else {
                ToolTipView(image: "lightbulb",
                            message: "Track your performance from here. Tap & hold charts for more info.",
                            color: .yellow)
            }
        }
    }
    
    var bankrollChart: some View {
        
        BankrollLineChart(showTitle: true, showYAxis: true, showRangeSelector: true, showPatternBackground: false, overlayAnnotation: false, showToggleAndFilter: true)
            .padding(.bottom, 5)
            .cardStyle(colorScheme: colorScheme, height: 475)
            .cardShadow(colorScheme: colorScheme)
    }
    
    var bankrollProgressView: some View {
        
        BankrollProgressView(progressIndicator: $progressIndicator, isSubscribed: subManager.isSubscribed)
            .onAppear(perform: {
                self.progressIndicator = viewModel.bankrollProgressRing
            })
            .onReceive(viewModel.$sessions, perform: { _ in
                self.progressIndicator = viewModel.bankrollProgressRing
            })
            .cardShadow(colorScheme: colorScheme)
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
    }
    
    var barChart: some View {
        
        BarChartByYear(showTitle: true, moreAxisMarks: true, cashOnly: false)
            .cardStyle(colorScheme: colorScheme, height: 380)
            .cardShadow(colorScheme: colorScheme)
    }
    
    var performanceChart: some View {
        
        VStack {
            if subManager.isSubscribed {
                
                PerformanceLineChart()
                    .cardStyle(colorScheme: colorScheme, height: 380)
                    .cardShadow(colorScheme: colorScheme)
                
            } else {
                PerformanceLineChart()
                    .cardStyle(colorScheme: colorScheme, height: 380)
                    .cardShadow(colorScheme: colorScheme)
                    .blur(radius: 3)
                    .allowsHitTesting(false)
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
        }
    }
    
    var dayOfWeekChart: some View {
        
        HStack {
            DayOfWeekChart(sessions: viewModel.allCashSessions())
                .padding(.leading, 7)
                .frame(width: UIScreen.main.bounds.width * 0.43, height: 190)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(12)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        }
    }
    
    var donutChart: some View {
        
        HStack {
            BestTimeOfDay()
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.43, height: 190)
                .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                .cornerRadius(12)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
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
        
        VStack {
            VStack (alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Player Stats")
                        .cardTitleStyle()
                    
                    Spacer()

                    Menu {
                        Picker("", selection: $sessionFilter) {
                            ForEach(SessionFilter.allCases, id: \.self) {
                                Text($0.rawValue.capitalized).tag($0)
                                    
                            }
                        }
                    } label: {
                        Text(sessionFilter.rawValue.capitalized + " ›")
                            .bodyStyle()
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                }
                .padding(.bottom)
                
                switch sessionFilter {
                case .all: AllStats(sessionFilter: sessionFilter, viewModel: viewModel, range: statsRange)
                case .cash: CashStats(sessionFilter: sessionFilter, viewModel: viewModel, range: statsRange)
                case .tournaments: TournamentStats(sessionFilter: sessionFilter, viewModel: viewModel, range: statsRange)
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

struct AllStats: View {
    
    @State private var highHandPopover = false
    @Environment(\.colorScheme) var colorScheme
    
    let sessionFilter: SessionFilter
    let viewModel: SessionsListViewModel
    let range: RangeSelection
    
    var body: some View {
        
        VStack {
            
            let currencyType = viewModel.userCurrency.rawValue
            let totalBankroll = viewModel.tallyBankroll(range: range, bankroll: sessionFilter)
            let hourlyRate = viewModel.hourlyRate(range: range, bankroll: sessionFilter)
            let profitPerSession = viewModel.avgProfit(range: range, bankroll: sessionFilter)
            let highHandBonus = viewModel.totalHighHands(range: range)
            let avgDuration = viewModel.avgDuration(range: range, bankroll: sessionFilter)
            let totalSessions = viewModel.countSessions(range: range, bankroll: sessionFilter)
            let totalWinRate = viewModel.totalWinRate(range: range, bankroll: sessionFilter)
            let totalHours = viewModel.totalHoursPlayed(range: range, bankroll: sessionFilter)
            let avgROI = viewModel.avgROI(range: range)
            let handsPlayed = viewModel.handsPlayed(range: range, bankroll: sessionFilter)
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
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .frame(height: 130)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                        .shadow(radius: 10)
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
    
    var body: some View {
        
        VStack {
            
            let currencyType = viewModel.userCurrency.rawValue
            let cashBankroll = viewModel.tallyBankroll(range: range, bankroll: sessionFilter)
            let hourlyRate = viewModel.hourlyRate(range: range, bankroll: sessionFilter)
            let profitPerSession = viewModel.avgProfit(range: range, bankroll: sessionFilter)
            let highHandBonus = viewModel.totalHighHands(range: range)
            let avgDuration = viewModel.avgDuration(range: range, bankroll: sessionFilter)
            let cashWinCount = viewModel.numOfCashes(range: range)
            let totalSessions = viewModel.countSessions(range: range, bankroll: sessionFilter)
            let cashWinRate = viewModel.totalWinRate(range: range, bankroll: sessionFilter)
            let cashTotalHours = viewModel.totalHoursPlayed(range: range, bankroll: sessionFilter)
            let handsPlayed = viewModel.handsPlayed(range: range, bankroll: sessionFilter)
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
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .frame(height: 130)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                        .shadow(radius: 10)
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
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                            .frame(height: 180)
                            .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                            .presentationCompactAdaptation(.popover)
                            .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                            .shadow(radius: 10)
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
    
    var body: some View {
        
        VStack {
            
            let tournamentProfit = viewModel.tallyBankroll(range: range, bankroll: .tournaments)
            let tournamentHourlyRate = viewModel.hourlyRate(range: range, bankroll: .tournaments)
            let tournamentAvgDuration = viewModel.avgDuration(range: range, bankroll: .tournaments)
            let avgTournamentBuyIn = viewModel.avgTournamentBuyIn(range: range)
            let tournamentCount = viewModel.tournamentCount(range: range)
            let avgRebuyCount = viewModel.averageTournamentRebuys(range: range)
            let itmRatio = viewModel.inTheMoneyRatio(range: range)
            let tournamentROI = viewModel.tournamentReturnOnInvestment(range: range)
            let tournamentHrsPlayed = viewModel.totalHoursPlayed(range: range, bankroll: .tournaments)
            let handsPlayed = viewModel.handsPlayed(range: range, bankroll: .tournaments)
            
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
            
            Divider()
            
            HStack {
                Text("Avg. No. of Rebuys")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(avgRebuyCount, specifier: "%.1f")")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
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
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                                                          description: "Review & export your results from the previous year.",
                                                          image: "list.clipboard",
                                                          color: .donutChartDarkBlue)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: SleepAnalytics(activeSheet: .constant(.none)),
                            label: {
                                AdditionalMetricsCardView(title: "Health Analytics",
                                                          description: "See how sleep & mindfulness affects your poker results.",
                                                          image: "stethoscope",
                                                          color: .lightGreen)
                                
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByMonth(vm: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Monthly Snapshot",
                                                          description: "View your results on a month by month basis.",
                                                          image: "calendar",
                                                          color: .donutChartGreen)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: AdvancedTournamentReport(vm: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Tournament Report",
                                                          description: "Advanced tournament stats, filtered by year.",
                                                          image: "person.2",
                                                          color: .brandPrimary)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByLocationView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Location Statistics",
                                                          description: "View your profit or loss for every location you've played at.",
                                                          image: "mappin.and.ellipse",
                                                          color: .donutChartRed)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByStakesView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Game Stakes",
                                                          description: "Break down your game by different table stakes.",
                                                          image: "dollarsign.circle",
                                                          color: .donutChartPurple)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: TagReport(),
                            label: {
                                AdditionalMetricsCardView(title: "Tag Report",
                                                          description: "Generate a report sorted via tags applied to your Sessions.",
                                                          image: "tag.fill",
                                                          color: .brandWhite)
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
