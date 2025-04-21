//
//  MericsView.playerStatsCard.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/13/25.
//

import SwiftUI

extension MetricsView {
    
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
}
