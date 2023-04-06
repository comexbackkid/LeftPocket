//
//  MetricsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct MetricsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.isPresented) var showMetricsSheet
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                ZStack {
                    
                    VStack (alignment: .leading) {
                        
                        if showMetricsSheet {
                            
                            Text("Metrics")
                                .titleStyle()
                        }
                        
                        Text("Explore your poker metrics here. Start adding sessions in order to chart your progress and manage your bankroll.")
                            .subtitleStyle()
                        
                        VStack (alignment: .center, spacing: 22) {
                            
                            if !viewModel.sessions.isEmpty {
                                
                                bankrollChart
                            }
                            
                            playerStats
                            
                            if !viewModel.sessions.isEmpty {
                                
                                BarChartView(vm: viewModel)
                            }
                            
                            AdditionalMetricsView()
                                .padding(.top, 10)
                        }
                    }
                    
                    if showMetricsSheet {
                        
                        dismissButton
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(showMetricsSheet ? true : false)
            .navigationBarTitle("Metrics")
        }
        .accentColor(.brandPrimary)
    }
    
    var bankrollChart: some View {
        
        CustomChartView(viewModel: viewModel, data: viewModel.chartCoordinates(), background: true)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 320)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .overlay(
                VStack (alignment: .leading) {
                    HStack {
                        Text("My Bankroll")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    
                    Text(viewModel.yearRangeFirst() + " - " + viewModel.yearRangeRecent())
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Spacer()
                }, alignment: .leading)
    }
    
    var dismissButton: some View {
        
        VStack {
            HStack {
                Spacer()
                DismissButton()
                    .padding(.trailing, 20)
                    .shadow(color: Color.black.opacity(0.2), radius: 8)
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
                        .font(.title2)
                        .bold()
                        .padding(.bottom)
                }
                
                VStack {
                    Group {
                        HStack {
                            Text("Total Bankroll")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.tallyBankroll().asCurrency())
                                .foregroundColor(viewModel.tallyBankroll() > 0 ? .green : viewModel.tallyBankroll() < 0 ? .red : .primary)
                        }
                        Divider()
                        HStack {
                            Text("Hourly Rate")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.hourlyRate().asCurrency())
                                .foregroundColor(viewModel.hourlyRate() > 0 ? .green : viewModel.tallyBankroll() < 0 ? .red : .primary)
                        }
                        Divider()
                        HStack {
                            Text("Profit Per Session")
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
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.avgDuration())
                        }
                        Divider()
                        HStack {
                            Text("Total Number of Cashes")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.numOfCashes())")
                        }
                        Divider()
                        HStack {
                            Text("Win Rate")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.winRate())
                        }
                        Divider()
                        HStack {
                            Text("Total Hours Played")
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
        .background(Color(.systemBackground))
        .cornerRadius(20)
        
    }
}

struct AdditionalMetricsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Additional Metrics")
                .font(.title2)
                .bold()
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack (spacing: 10) {
                    
                    NavigationLink(
                        destination: ProfitByYear(viewModel: viewModel, vm: AnnualReportViewModel()),
                        label: {
                            FilterCardView(image: "doc.text",
                                           imageColor: .cyan,
                                           title: "My Annual\nReport",
                                           description: "Compare year-over-year results.")
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByMonth(vm: viewModel),
                        label: {
                            FilterCardView(image: "calendar",
                                           imageColor: .purple,
                                           title: "Profit by\nMonth",
                                           description: "Review your hottest win streaks.")
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    
                    NavigationLink(
                        destination: ProfitByLocationView(viewModel: viewModel),
                        label: {
                            FilterCardView(image: "mappin.and.ellipse",
                                           imageColor: .red,
                                           title: "Profit by\nLocation",
                                           description: "Which location yields the best return.")
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByWeekdayView(vm: viewModel),
                        label: {
                            FilterCardView(image: "sun.max",
                                           imageColor: .yellow,
                                           title: "Profit by\nWeekday",
                                           description: "Snapshot of day-to-day performance.")
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByStakesView(viewModel: viewModel),
                        label: {
                            FilterCardView(image: "dollarsign.circle",
                                           imageColor: .green,
                                           title: "Profit by\nStakes",
                                           description: "Which stakes do you need help with?")
                        })
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.leading)
                .padding(.trailing)
                .frame(height: 200)
            })
        }
        .padding(.bottom, 30)
    }
}

struct MetricsView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetricsView().environmentObject(SessionsListViewModel())
    }
}
