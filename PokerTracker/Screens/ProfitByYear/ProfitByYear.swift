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
    @StateObject var vm: yearlySummaryViewModel
    
    var body: some View {
        
        let newTimeline = vm.myNewTimeline
        let netProfitTotal = vm.netProfitCalc(timeline: vm.myNewTimeline)
        let hourlyRate = vm.hourlyCalc(timeline: vm.myNewTimeline)
        let profitPerSession = vm.avgProfit(timeline: vm.myNewTimeline)
        let totalExpenses = vm.expensesByYear(timeline: vm.myNewTimeline)
        let totalHours = vm.totalHours(timeline: vm.myNewTimeline)

        ScrollView {
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
                        Spacer()
                        Text("\(netProfitTotal.asCurrency())").profitColor(total: netProfitTotal)
                    }
                    
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        Text("\(hourlyRate.asCurrency())").profitColor(total: hourlyRate)
                    }
                    
                    HStack {
                        Text("Profit Per Session")
                        Spacer()
                        Text("\(profitPerSession.asCurrency())").profitColor(total: profitPerSession)
                    }
                    
                    HStack {
                        Text("Total Expenses")
                        Spacer()
                        Text("\(totalExpenses.asCurrency())")
                    }
                    
                    HStack {
                        Text("Total Hours")
                        Spacer()
                        Text(totalHours)
                    }
                    
                    Spacer()
                    
                }
                .font(.subheadline)
                .animation(nil, value: vm.myNewTimeline)
                .padding(30)
                .frame(width: 340, height: 180)
                .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)

                Spacer()
            }
            .navigationBarTitle("Yearly Summary")
        }
        
        
    }
}

struct ProfitByYear_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByYear(viewModel: SessionsListViewModel(), vm: yearlySummaryViewModel())
    }
}
