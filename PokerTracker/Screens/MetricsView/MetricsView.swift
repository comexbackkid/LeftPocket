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
    
    @State var progressIndicator: Float = 0.0
    @State var sessionFilter: SessionFilter = .cash
    @Binding var activeSheet: Sheet?
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack {
                    
                    if viewModel.sessions.isEmpty {
                        
                        EmptyState(image: .metrics)
                            .padding(.bottom, 50)
                        
                    } else {
                        
                        ScrollView {
                            
                            VStack (spacing: 22) {
                                
                                HStack {
                                    
                                    Text("Metrics")
                                        .titleStyle()
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                }
                                
                                ToolTipView(image: "lightbulb",
                                            message: "Track your performance from here. Tap & hold charts for more info.",
                                            color: .yellow)
                                
                                bankrollChart
                                
                                BankrollProgressView(progressIndicator: $progressIndicator)
                                    .onAppear(perform: {
                                        self.progressIndicator = viewModel.stakesProgress
                                    })
                                    .onReceive(viewModel.$sessions, perform: { _ in
                                        self.progressIndicator = viewModel.stakesProgress
                                    })
                                
                                playerStats
                                
                                ToolTipView(image: "calendar",
                                            message: "Your best month so far this year has been \(viewModel.bestMonth).",
                                            color: .brandPrimary)
                                
                                barChart
                                
                                ToolTipView(image: "stopwatch",
                                            message: "You tend to play better when your session lasts \(viewModel.bestSessionLength()).",
                                            color: .donutChartDarkBlue)

                                if #available(iOS 17.0, *) {
                                    HStack {
                                        donutChart
                                        Spacer()
                                        heatMap
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                }
                                
                                HStack {
                                    Text("My Reports")
                                        .font(.custom("Asap-Black", size: 34))
                                        .bold()
                                        .padding(.horizontal)
                                        .padding(.top)
                                    
                                    Spacer()
                                }
                                
                                AdditionalMetricsView()
                                    .padding(.bottom, activeSheet == .metricsAsSheet ? 0 : 50)
                            }
                            
                        }
                        .fullScreenCover(isPresented: $viewModel.lineChartFullScreen, content: {
                            LineChartFullScreen(lineChartFullScreen: $viewModel.lineChartFullScreen)
                        })
                    }
                }
                .frame(maxHeight: .infinity)
                .background(Color.brandBackground)
                .navigationBarHidden(true)
                .onAppear {
                    AppReviewRequest.requestReviewIfNeeded()
                }
                
                if activeSheet == .metricsAsSheet { dismissButton }
                
            }
            .background(Color.brandBackground)
        }
        .accentColor(.brandPrimary)
    }
    
    var bankrollChart: some View {
        
        BankrollLineChart(showTitle: true, showYAxis: true, showRangeSelector: true, overlayAnnotation: false)
            .padding(.top)
            .padding(.bottom, 20)
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 370)
            .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
            .cornerRadius(20)
    }
    
    var barChart: some View {
        
        BarChartByYear(showTitle: true, moreAxisMarks: true, cashOnly: false)
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 380)
            .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
            .cornerRadius(20)
        
    }
    
    @available(iOS 17.0, *)
    var heatMap: some View {
        
        HStack {
            HeatMap()
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.43, height: 190)
                .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
                .cornerRadius(20)
        }
    }
    
    @available(iOS 17.0, *)
    var donutChart: some View {
        
        HStack {
            BestTimeOfDay()
                .padding()
                .padding(.top, 6)
                .frame(width: UIScreen.main.bounds.width * 0.43, height: 190)
                .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
                .cornerRadius(20)
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
                case .all:
                    AllStats(sessionFilter: sessionFilter, viewModel: viewModel)
                case .cash:
                    CashStats(sessionFilter: sessionFilter, viewModel: viewModel)
                case .tournaments:
                    TournamentStats(sessionFilter: sessionFilter, viewModel: viewModel)
                }
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
    }
}

struct AllStats: View {
    
    let sessionFilter: SessionFilter
    let viewModel: SessionsListViewModel
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Total Bankroll")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.tallyBankroll(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.tallyBankroll(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.tallyBankroll(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack {
                Text("Hourly Rate")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.hourlyRate(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.hourlyRate(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.hourlyRate(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack {
                Text("Profit Per Session")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.avgProfit(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.avgProfit(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.avgProfit(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack {
                Text("Avg. Duration")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.avgDuration(bankroll: sessionFilter))
            }
            
            Divider()
            
            HStack {
                Text("Total No. of Sessions")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.sessions.count)")
            }
            
            Divider()
            
            HStack {
                Text("Win Ratio")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.totalWinRate())
            }
            
            Divider()
            
            HStack {
                Text("Total Hours Played")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.totalHoursPlayed(bankroll: sessionFilter))
            }
            
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
    }
}

struct CashStats: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var highHandPopover = false
    
    let sessionFilter: SessionFilter
    let viewModel: SessionsListViewModel
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Bankroll")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.tallyBankroll(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.tallyBankroll(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.tallyBankroll(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack {
                Text("Hourly Rate")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.hourlyRate(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.hourlyRate(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.hourlyRate(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack {
                Text("Profit Per Session")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.avgProfit(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.avgProfit(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.avgProfit(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack (alignment: .lastTextBaseline, spacing: 4) {
                Text("High Hand Bonuses")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Button {
                    highHandPopover = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color.brandPrimary)
                }
                .popover(isPresented: $highHandPopover, arrowEdge: .bottom, content: {
                    PopoverView(bodyText: "High hand bonuses are not counted towards your bankroll or player metrics. They are tallied in your Annual Report.")
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .frame(height: 130)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                        .shadow(radius: 10)
                })
                
                Spacer()
                Text(viewModel.totalHighHands(), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.totalHighHands() > 0 ? .green : .primary)
                                    
            }
            
            Divider()
            
            HStack {
                Text("Avg. BB / Hr")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.bbPerHour(), specifier: "%.2f")")
            }
            
            Divider()
            
            HStack {
                Text("Avg. Duration")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.avgDuration(bankroll: sessionFilter))
            }
            
            Divider()
            
            HStack {
                Text("No. of Cashes")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.numOfCashes())")
            }
            
            Divider()
            
            // Needs to filter just for cash games
            HStack {
                Text("Win Ratio")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.winRate())
            }
            
            Divider()
            
            HStack {
                Text("Hours Played")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.totalHoursPlayed(bankroll: sessionFilter))
            }
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
    }
}

struct TournamentStats: View {
    
    let sessionFilter: SessionFilter
    let viewModel: SessionsListViewModel
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Bankroll")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.tallyBankroll(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.tallyBankroll(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.tallyBankroll(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack {
                Text("Hourly Rate")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.hourlyRate(bankroll: sessionFilter), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(viewModel.hourlyRate(bankroll: sessionFilter) > 0 ? .green
                                     : viewModel.hourlyRate(bankroll: sessionFilter) < 0 ? .red
                                     : .primary)
            }
            
            Divider()
            
            HStack {
                Text("Avg. Duration")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.avgDuration(bankroll: sessionFilter))
            }
            
            Divider()
            
            HStack {
                Text("Avg. Buy In")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.avgTournamentBuyIn(), format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
            }
            
            Divider()
            
            HStack {
                Text("Total Buy Ins")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.sessions.filter({ $0.isTournament == true }).count)")
            }
            
            Divider()
            
            HStack {
                Text("ITM Ratio")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.inTheMoneyRatio())
            }
            
            Divider()
            
            HStack {
                Text("ROI")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.tournamentReturnOnInvestment())
            }
            
            Divider()
            
            HStack {
                Text("Hours Played")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.totalHoursPlayed(bankroll: sessionFilter))
            }
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
    }
}

struct ToolTipView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let image: String
    let message: String
    let color: Color
    
    var body: some View {
        
        HStack {
            
            Image(systemName: image)
                .foregroundColor(color)
                .font(.system(size: 25, weight: .bold))
                .padding(.trailing, 10)
                .frame(width: 40)
            
            Text(message)
                .calloutStyle()
            
            Spacer()
            
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
    }
}

struct AdditionalMetricsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var showPaywall = false
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            // Adding version check for scroll behavior effect
            if #available(iOS 17, *) {
                
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack (spacing: 12) {
                        
                        NavigationLink(
                            destination: ProfitByYear(vm: AnnualReportViewModel()),
                            label: {
                                AdditionalMetricsCardView(title: "Annual Report",
                                                          description: "Review & export your results from \nthe previous year.",
                                                          image: "list.clipboard",
                                                          color: .donutChartDarkBlue)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        if subManager.isSubscribed {
                            
                            NavigationLink(
                                destination: SleepAnalytics(activeSheet: .constant(.none)),
                                label: {
                                    AdditionalMetricsCardView(title: "Sleep Analytics",
                                                              description: "See how your sleep is affecting\nyour poker results.",
                                                              image: "bed.double.fill",
                                                              color: .donutChartOrange)
                                    
                                })
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            
                            AdditionalMetricsCardView(title: "Sleep Analytics",
                                                      description: "See how your sleep is affecting\nyour poker results.",
                                                      image: "bed.double.fill",
                                                      color: Color(.systemGray4))
                            .blur(radius: 2)
                            .overlay {
                                Button {
                                   showPaywall = true
                                } label: {
                                    Text("Upgrade for Access")
                                        .buttonTextStyle()
                                        .frame(height: 55)
                                        .frame(width: UIScreen.main.bounds.width * 0.6)
                                        .background(Color.brandPrimary)
                                        .foregroundColor(.white)
                                        .cornerRadius(30)
                                        .shadow(color: .black, radius: 20)
                                }
                            }
                        }
                        
                        NavigationLink(
                            destination: ProfitByMonth(vm: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Monthly Snapshot",
                                                          description: "View your results on a month by \nmonth basis.",
                                                          image: "calendar",
                                                          color: .donutChartGreen)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByLocationView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Location Statistics",
                                                          description: "View your profit or loss for every \nlocation you've played at.",
                                                          image: "mappin.and.ellipse",
                                                          color: .donutChartRed)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByStakesView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Game Stakes", 
                                                          description: "Break down your game by different \ntable stakes.",
                                                          image: "dollarsign.circle",
                                                          color: .donutChartPurple)
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
                
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack (spacing: 12) {
                        
                        NavigationLink(
                            destination: ProfitByYear(vm: AnnualReportViewModel()),
                            label: {
                                AdditionalMetricsCardView(title: "Annual Report",
                                                          description: "Review & export your results from \nthe previous year.",
                                                          image: "list.clipboard",
                                                          color: .donutChartDarkBlue)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        if subManager.isSubscribed {
                            
                            NavigationLink(
                                destination: SleepAnalytics(activeSheet: .constant(.none)),
                                label: {
                                    AdditionalMetricsCardView(title: "Sleep Analytics",
                                                              description: "See how your sleep is affecting\nyour poker results.",
                                                              image: "bed.double.fill",
                                                              color: .donutChartOrange)
                                    
                                })
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            
                            AdditionalMetricsCardView(title: "Sleep Analytics",
                                                      description: "See how your sleep is affecting\nyour poker results.",
                                                      image: "bed.double.fill",
                                                      color: Color(.systemGray4))
                            .blur(radius: 2)
                            .overlay {
                                Button {
                                   showPaywall = true
                                } label: {
                                    Text("Upgrade for Access")
                                        .buttonTextStyle()
                                        .frame(height: 55)
                                        .frame(width: UIScreen.main.bounds.width * 0.6)
                                        .background(Color.brandPrimary)
                                        .foregroundColor(.white)
                                        .cornerRadius(30)
                                        .shadow(color: .black, radius: 20)
                                }
                            }
                        }
                        
                        NavigationLink(
                            destination: ProfitByMonth(vm: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Monthly Snapshot",
                                                          description: "View your results on a month by \nmonth basis.",
                                                          image: "calendar",
                                                          color: .donutChartGreen)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        NavigationLink(
                            destination: ProfitByLocationView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Location Statistics",
                                                          description: "View your profit or loss for every \nlocation you've played at.",
                                                          image: "mappin.and.ellipse",
                                                          color: .donutChartRed)
                            })
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(
                            destination: ProfitByStakesView(viewModel: viewModel),
                            label: {
                                AdditionalMetricsCardView(title: "Game Stakes",
                                                          description: "Break down your game by different \ntable stakes.",
                                                          image: "dollarsign.circle",
                                                          color: .donutChartPurple)
                            })
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .frame(height: 150)
                })
                
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
