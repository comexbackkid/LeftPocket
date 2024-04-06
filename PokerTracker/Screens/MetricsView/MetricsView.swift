//
//  MetricsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import TipKit

struct MetricsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.isPresented) var showMetricsSheet
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State var progressIndicator: Float = 0.0
    @State var sessionFilter: SessionFilter = .cash
    
    var body: some View {
        
        NavigationView {
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
                                            message: "Measure your performance & track progress from this screen.",
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
                                
                                AdditionalMetricsView()
                                    
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .background(Color.brandBackground)
                .navigationBarHidden(true)
                
                if showMetricsSheet { dismissButton }
                
            }
            .background(Color.brandBackground)
        }
        .accentColor(.brandPrimary)
    }
    
    var bankrollChart: some View {
        
        SwiftLineChartsPractice(dateRange: viewModel.sessions, showTitle: true, showYAxis: true, overlayAnnotation: false)
            .padding(.top)
            .padding(.bottom, 40)
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 340)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
    }
    
    var barChart: some View {
        
        BarChartByYear(showTitle: true)
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 400)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
        
    }
    
    var dismissButton: some View {
        
        VStack {
            HStack {
                Spacer()
                DismissButton()
                    .padding(.trailing, 20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8)
                    .onTapGesture {
                        dismiss()
                    }
            }
            Spacer()
        }
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
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
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
            
            // Win Rate is wrong, it's just calculating everything
            HStack {
                Text("Win Rate")
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
            
            HStack {
                Text("BB Per Hour")
                    .calloutStyle()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.bigBlindperHour(), specifier: "%.2f")")
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
                Text("Win Rate")
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
            
            Text(message)
                .calloutStyle()
            
            Spacer()
            
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
    }
}

struct AdditionalMetricsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            Text("Reports & Analytics")
                .cardTitleStyle()
                .bold()
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack (spacing: 10) {
                    
                    NavigationLink(
                        destination: ProfitByYear(vm: AnnualReportViewModel()),
                        label: {
                            AdditionalMetricsCardView(title: "Annual Report",
                                                      description: "Review & export results from the \nprevious year.",
                                                      image: "list.clipboard",
                                                      color: .blue)
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByMonth(vm: viewModel),
                        label: {
                            AdditionalMetricsCardView(title: "Profit by Month",
                                                      description: "View results based on a month by \nmonth basis.",
                                                      image: "calendar",
                                                      color: .mint)
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    
                    NavigationLink(
                        destination: ProfitByLocationView(viewModel: viewModel),
                        label: {
                            AdditionalMetricsCardView(title: "Location Statistics",
                                                      description: "View your profit or loss for every \nlocation you've played at.",
                                                      image: "mappin.and.ellipse",
                                                      color: .red)
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByStakesView(viewModel: viewModel),
                        label: {
                            AdditionalMetricsCardView(title: "Game Stakes", description: "Break down your game \nby table stakes.", image: "dollarsign.circle", color: .green)
                        })
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.leading)
                .padding(.trailing)
                .frame(height: 150)
            })
        }
        .padding(.bottom, 50)
        .padding(.top, 10)
    }
}

struct MetricsView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetricsView().environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
