//
//  MetricsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import SwiftUICharts

struct MetricsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                if viewModel.sessions.isEmpty {
                    
                    VStack {
                        EmptyStateMetricsBankroll()
                            .padding(.top, 50)
                            .padding(.bottom, 50)
                    }
                }
                
                    VStack (alignment: .leading) {
                        
                        if !viewModel.sessions.isEmpty {
                            BankrollChartView()
                                .padding(.top)
                        }
                        
                        OverviewView(totalBankroll: viewModel.tallyBankroll(),
                                     hourlyRate: viewModel.hourlyRate(),
                                     avgProfit: viewModel.avgProfit(),
                                     avgSessionDuration: viewModel.avgDuration(),
                                     numOfCashes: viewModel.numOfCashes(),
                                     totalHours: viewModel.totalHoursPlayed())
                        
                        VStack (alignment: .leading) {
                            
                            if !viewModel.sessions.isEmpty {
                                HStack {
                                    BarGraphView()
                                        .frame(height: 320)
                                }
                                .padding(.vertical, 30)
                            }
                            
                            AdditionalMetricsView()
                                .padding(.top, 10)
                        }
                    }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MetricsView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetricsView().environmentObject(SessionsListViewModel())
    }
}

struct BankrollChartView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    let lineChartStyle = ChartStyle(backgroundColor: Color(.systemBackground),
                                    accentColor: .brandPrimary,
                                    secondGradientColor: Color("lightBlue"),
                                    textColor: .black, legendTextColor: .gray,
                                    dropShadowColor: .white)
    
    var body: some View {
        
        Text("Your Bankroll")
            .font(.title)
            .bold()
            .padding(.horizontal)
        
        LineView(data: viewModel.chartArray(),
                 //  title: "Title",
                 //  legend: "Bankroll Tracker",
                 style: lineChartStyle,
                 valueSpecifier: "%.0f",
                 legendSpecifier: "%0.f"
        )
        .offset(y:-10)
        .padding(.horizontal)
        .frame(height: 290)
        
    }
}

struct OverviewView: View {
    
    let totalBankroll: Int
    let hourlyRate: Int
    let avgProfit: Int
    let avgSessionDuration: String
    let numOfCashes: Int
    let totalHours: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            HStack {
                Text("Overview")
                    .font(.title)
                    .bold()
                    .padding(.bottom)
            }
            VStack {
                Group {
                    HStack {
                        Text("Total Bankroll")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$" + "\(totalBankroll)")
                            .foregroundColor(totalBankroll > 0 ? .green : totalBankroll < 0 ? .red : .black)
                    }
                    Divider()
                    HStack {
                        Text("Hourly Rate")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$" + "\(hourlyRate)")
                            .foregroundColor(hourlyRate > 0 ? .green : totalBankroll < 0 ? .red : .black)
                    }
                    Divider()
                    HStack {
                        Text("Profit Per Session")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$" + "\(avgProfit)")
                            .foregroundColor(avgProfit > 0 ? .green : totalBankroll < 0 ? .red : .black)
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
}

struct AdditionalMetricsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Additional Metrics")
                .font(.title)
                .bold()
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack (spacing: 10) {
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
                                           description: "Some days you're hot, some you're not.")
                        })
                        .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByMonth(yearSelection: "2021", viewModel: viewModel),
                        label: {
                            FilterCardView(image: "calendar",
                                           imageColor: .purple,
                                           title: "Profit by\nMonth",
                                           description: "Review your year over year results.")
                        })
                        .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(
                        destination: ProfitByStakesView(viewModel: viewModel),
                        label: {
                            FilterCardView(image: "suit.spade",
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
