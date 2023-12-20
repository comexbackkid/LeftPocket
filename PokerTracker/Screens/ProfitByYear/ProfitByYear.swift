//
//  ProfitByYear.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/4/22.
//

import SwiftUI

struct ProfitByYear: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: SessionsListViewModel
    @StateObject var vm: AnnualReportViewModel
    
    var body: some View {
        
        let newTimeline = vm.myNewTimeline
        let netProfitTotal = vm.netProfitCalc(timeline: vm.myNewTimeline)
        let hourlyRate = vm.hourlyCalc(timeline: vm.myNewTimeline)
        let profitPerSession = vm.avgProfit(timeline: vm.myNewTimeline)
        let winRate = vm.winRate(timeline: vm.myNewTimeline)
        let totalExpenses = vm.expensesByYear(timeline: vm.myNewTimeline)
        let totalHours = vm.totalHours(timeline: vm.myNewTimeline)
        let bestLocation = vm.bestLocation(timeline: vm.myNewTimeline)
        let bestProfit = vm.bestProfit(timeline: vm.myNewTimeline)

        ScrollView {
            
            HStack {
                
                Text("Annual Report")
                    .titleStyle()
                    .padding(.top, -37)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            VStack {
                
                ZStack {
                    
                    Color.clear
                    
                    if !vm.isLoading {
                        
                        CustomChartView(viewModel: viewModel, data: vm.chartData(timeline: newTimeline), background: false)
                            .padding(.bottom)
                            .frame(height: 280)
                        
                    } else {
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                    }
                }
                .frame(height: 280)
                
                CustomPicker(vm: vm)
                    .padding(.bottom, 35)
                    .padding(.top)
                
                VStack (spacing: 12) {
                    Spacer()
                    HStack {
                        Text("Net Profit")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(netProfitTotal.asCurrency())").profitColor(total: netProfitTotal)
                    }
                    
                    HStack {
                        Text("Hourly Rate")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(hourlyRate.asCurrency())").profitColor(total: hourlyRate)
                    }
                    
                    HStack {
                        Text("Profit Per Session")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(profitPerSession.asCurrency())").profitColor(total: profitPerSession)
                    }
                    
                    HStack {
                        Text("Expenses")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(totalExpenses.asCurrency())")
                    }
                    
                    HStack {
                        Text("Win Rate")
                            .bodyStyle()
                        
                        Spacer()
                        Text(winRate)
                    }
                    
                    HStack {
                        Text("Hours Played")
                            .bodyStyle()
                        
                        Spacer()
                        Text(totalHours)
                    }
                    
                    Spacer()
                    
                }
                .animation(nil, value: vm.myNewTimeline)
                .padding(30)
                .frame(width: 340, height: 240)
                .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                
                VStack (spacing: 30) {
                    
                    BestSessionView(profit: bestProfit)
                    
                    BestLocationView(location: bestLocation)
                    
//                    PrimaryButton(title: "Export My Data")
//                        .onTapGesture {
//                            viewModel.writeUserData()
//                        }
                    
                }
                .animation(nil, value: vm.myNewTimeline)
                .padding(.top, 20)
                .padding(.bottom, 50)

                Spacer()
            }
            .padding(.bottom, 50)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
        }
        .background(Color.brandBlack)
        .accentColor(.brandPrimary)
    }
}

struct ProfitByYear_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByYear(viewModel: SessionsListViewModel(), vm: AnnualReportViewModel())
            .preferredColorScheme(.dark)
    }
}
