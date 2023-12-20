//
//  MetricsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct MetricsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.isPresented) var showMetricsSheet
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                VStack {
                    
                    if viewModel.sessions.isEmpty {
                        
                        EmptyState(screen: .metrics)
                        
                    } else {
                        
                        ScrollView {
                            
                            VStack (spacing: 22) {
                                
                                HStack {
                                    
                                    Text("Metrics")
                                        .titleStyle()
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                }
                                
                                toolTip
                                
                                bankrollChart
                                
                                playerStats
                                
                                BarChartView(vm: viewModel)
                                
                                AdditionalMetricsView()
                                    .padding(.top, 10)
                                    .padding(.bottom, 50)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .background(Color.brandBlack)
                .navigationBarHidden(true)
                
                if showMetricsSheet {
                    dismissButton
                }
            }
        }
        .accentColor(.brandPrimary)
    }
    
    var toolTip: some View {
        
        HStack {
            
            Image(systemName: "lightbulb")
                .foregroundColor(.yellow)
                .font(.system(size: 25, weight: .bold))
                .padding(.trailing, 10)
            
            Text("Measure your performance & track progress from this screen.")
                .calloutStyle()
            
            Spacer()
                
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
    }
    
    var bankrollChart: some View {
        
        CustomChartView(viewModel: viewModel, data: viewModel.chartCoordinates(), background: true)
            .padding(.top, 25)
            .padding(.bottom, 20)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 300)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .overlay(
                VStack (alignment: .leading) {
                    HStack {
                        Text("My Bankroll")
                            .cardTitleStyle()
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    
                    Spacer()
                    
                }, alignment: .leading)
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
                        .padding(.bottom)
                }
                
                VStack {
                    Group {
                        HStack {
                            Text("Total Bankroll")
                                .calloutStyle()
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.tallyBankroll().asCurrency())
                                .foregroundColor(viewModel.tallyBankroll() > 0 ? .green : viewModel.tallyBankroll() < 0 ? .red : .primary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Hourly Rate")
                                .calloutStyle()
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.hourlyRate().asCurrency())
                                .foregroundColor(viewModel.hourlyRate() > 0 ? .green : viewModel.tallyBankroll() < 0 ? .red : .primary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Profit Per Session")
                                .calloutStyle()
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.avgProfit().asCurrency())
                                .foregroundColor(viewModel.avgProfit() > 0 ? .green : viewModel.tallyBankroll() < 0 ? .red : .primary)
                        }
                    }
                    
                    Group {
                        
                        Divider()
                        
                        HStack {
                            Text("Average Session Duration")
                                .calloutStyle()
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.avgDuration())
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Number of Cashes")
                                .calloutStyle()
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.numOfCashes())")
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Win Rate")
                                .calloutStyle()
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.winRate())
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Hours Played")
                                .calloutStyle()
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.totalHoursPlayed())
                        }
                    }
                    Spacer()
                }
                .font(.subheadline)
            }
            .padding()
        }
        
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        
    }
}

struct AdditionalMetricsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            Text("In-Depth Metrics")
                .cardTitleStyle()
                .font(.title2)
                .bold()
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack (spacing: 10) {
                    
                    NavigationLink(
                        destination: ProfitByYear(viewModel: viewModel, vm: AnnualReportViewModel()),
                        label: {
                            AdditionalMetricsCardView(title: "Annual Report",
                                                      description: "Review results and stats for \na given year.",
                                                      image: "list.clipboard",
                                                      color: .blue)
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByMonth(vm: viewModel),
                        label: {
                            AdditionalMetricsCardView(title: "Profit by Month",
                                                      description: "View results based upon month.",
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
                            AdditionalMetricsCardView(title: "Game Stakes", description: "Break down your game \nby table stakes", image: "dollarsign.circle", color: .green)
                        })
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.leading)
                .padding(.trailing)
                .frame(height: 150)
            })
        }
        .padding(.bottom, 30)
    }
}

struct MetricsView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetricsView().environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
