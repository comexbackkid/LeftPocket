//
//  MetricsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import SwiftUICharts

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
                            Text("My Metrics")
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading)
                                .padding(.bottom, 8)
                                .padding(.top, 40)
                        }
                        
                        Text("Explore your poker metrics here. Start adding sessions in order to chart your progress and bankroll.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        
                        VStack (alignment: .center, spacing: 22) {
                             
                            if !viewModel.sessions.isEmpty {
                                
                                bankrollChart
                            }
                            
                            PlayerStatsView(totalBankroll: viewModel.tallyBankroll(),
                                            hourlyRate: viewModel.hourlyRate(),
                                            avgProfit: viewModel.avgProfit(),
                                            avgSessionDuration: viewModel.avgDuration(),
                                            numOfCashes: viewModel.numOfCashes(),
                                            profitableSessions: viewModel.profitableSessions(),
                                            totalHours: viewModel.totalHoursPlayed())
                            
                            if !viewModel.sessions.isEmpty {
                                
                                BarGraphView()
                                    .padding(.vertical)
                                    .frame(height: 425)
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(20)
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
            .navigationBarTitle("My Metrics")
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
                        Text("Current Bankroll")
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
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                    .onTapGesture {
                        dismiss()
                    }
            }
            Spacer()
        }
    }
}

struct PlayerStatsView: View {
    
    let totalBankroll: Int
    let hourlyRate: Int
    let avgProfit: Int
    let avgSessionDuration: String
    let numOfCashes: Int
    let profitableSessions: String
    let totalHours: String
    
    var body: some View {
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
                            Text("\(totalBankroll.accountingStyle())")
                                .foregroundColor(totalBankroll > 0 ? .green : totalBankroll < 0 ? .red : .primary)
                        }
                        Divider()
                        HStack {
                            Text("Hourly Rate")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$" + "\(hourlyRate)")
                                .foregroundColor(hourlyRate > 0 ? .green : totalBankroll < 0 ? .red : .primary)
                        }
                        Divider()
                        HStack {
                            Text("Profit Per Session")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(avgProfit.accountingStyle())")
                                .foregroundColor(avgProfit > 0 ? .green : totalBankroll < 0 ? .red : .primary)
                        }
                    }
                    Group {
                        Divider()
                        HStack {
                            Text("Average Session Duration")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(avgSessionDuration)
                        }
                        Divider()
                        HStack {
                            Text("Total Number of Cashes")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(numOfCashes)")
                        }
                        Divider()
                        HStack {
                            Text("Profitable Sessions")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(profitableSessions)
                        }
                        Divider()
                        HStack {
                            Text("Total Hours Played")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(totalHours)
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
                        destination: ProfitByYear(viewModel: viewModel, pbyViewModel: ProfitByYearViewModel()),
                        label: {
                            FilterCardView(image: "doc.text",
                                           imageColor: .cyan,
                                           title: "My Annual\nReport",
                                           description: "Compare year-over-year results.")
                        })
                        .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByMonth(viewModel: viewModel),
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
                        destination: ProfitByWeekdayView(viewModel: viewModel),
                        label: {
                            FilterCardView(image: "clock.arrow.circlepath",
                                           imageColor: .blue,
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
