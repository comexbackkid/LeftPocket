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
                    VStack {
                        if viewModel.sessions.isEmpty {
            
                                EmptyStateMetricsBankroll()
                                    .padding(.top, 50)
                                    .padding(.bottom, 50)
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
                            
                            if !viewModel.sessions.isEmpty {
                                
                                BarGraphView()
                                    .padding(.vertical, 25)
                                    .frame(height: 425)
                            }
                            
                            AdditionalMetricsView()
                                .padding(.top, 10)
                        }
                    }
                    
                    if showMetricsSheet {
                        
                        VStack {
                            HStack {
                                Spacer()
                                DismissButton()
                                    .padding(.trailing, 20)
                                    .padding(.top, 20)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                                    .onTapGesture {
                                        dismiss()
                                    }
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .accentColor(.brandPrimary)
    }
}

struct BankrollChartView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    let lineChartStyle = ChartStyle(backgroundColor: Color(.systemBackground),
                                    accentColor: .chartBase,
                                    secondGradientColor: .chartAccent,
                                    textColor: .black, legendTextColor: .gray,
                                    dropShadowColor: .white)
    
    var body: some View {
        
        Text("Your Bankroll")
            .font(.title)
            .bold()
            .padding(.horizontal)
        
        LineView(data: viewModel.chartArray(),
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
                        Text("$" + "\(avgProfit)")
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
                        destination: ProfitByYear(viewModel: viewModel, pbyViewModel: ProfitByYearViewModel()),
                        label: {
                            FilterCardView(image: "doc.text",
                                           imageColor: .cyan,
                                           title: "Profit by\nYear",
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
                                           description: "Some days you're hot, some you're not.")
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
