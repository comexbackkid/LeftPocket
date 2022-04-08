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
    @StateObject var pbyViewModel: ProfitByYearViewModel
    
    var body: some View {
        
        let timeline = pbyViewModel.selectedTimeline
        
        ScrollView {
            VStack {
                ZStack {
                    
                    Color.clear
                    
                    // We're saying if the selectedTimeline doesn't equal *this* year, then display data for all years
                    if !pbyViewModel.isLoading {
                        CustomChartView(data: timeline == "All"
                                        ? viewModel.chartCoordinates()
                                        : viewModel.yearlyChartCoordinates(year: timeline == "YTD"
                                                                           ? Date().getYear()
                                                                           : timeline))
                            .padding(.bottom)
                            .frame(height: 280)
                        
                    } else {
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                    }
                }
                .frame(height: 280)
                
                CustomPicker(pbyViewModel: pbyViewModel)
                    .padding(.bottom, 25)
                    .padding(.top)
                
                VStack (spacing: 15) {
                    Spacer()
                    HStack {
                        Text("Net Profit")
                        Spacer()
                        Text(timeline == "All"
                             ? "\(viewModel.tallyBankroll().accountingStyle())"
                             : viewModel.bankrollByYear(year: timeline == "YTD"
                                                        ? Date().getYear()
                                                        : timeline).accountingStyle())
                            .bold()
                            .modifier(AccountingView(total: timeline == "All"
                                                     ? viewModel.tallyBankroll()
                                                     : viewModel.bankrollByYear(year: timeline == "YTD"
                                                                                ? Date().getYear()
                                                                                : timeline)))
                    }
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        Text(timeline == "All"
                             ? "\(viewModel.hourlyRate().accountingStyle())"
                             : viewModel.hourlyByYear(year: timeline == "YTD"
                                                      ? Date().getYear()
                                                      : timeline).accountingStyle())
                            .bold()
                            .modifier(AccountingView(total: timeline == "All"
                                                     ? viewModel.hourlyRate()
                                                     : viewModel.hourlyByYear(year: timeline == "YTD"
                                                                              ? Date().getYear()
                                                                              : timeline)))
                    }
                    HStack {
                        Text("Profit Per Session")
                        Spacer()
                        Text(timeline == "All"
                             ? "\(viewModel.avgProfit().accountingStyle())"
                             : viewModel.avgProfitByYear(year: timeline == "YTD"
                                                         ? Date().getYear()
                                                         : timeline).accountingStyle())
                            .bold()
                            .modifier(AccountingView(total: timeline == "All"
                                                     ? viewModel.avgProfit()
                                                     : viewModel.avgProfitByYear(year: timeline == "YTD"
                                                                                 ? Date().getYear()
                                                                                 : timeline)))
                    }
                    HStack {
                        Text("Total Hours")
                        Spacer()
                        Text(timeline == "All"
                             ? "\(viewModel.totalHoursPlayed())"
                             : viewModel.hoursPlayedByYear(year: timeline == "YTD"
                                                           ? Date().getYear()
                                                           : timeline))
                    }
                    Spacer()
                    
                }
                .animation(nil, value: pbyViewModel.selectedTimeline)
                .padding(30)
                .frame(width: 340, height: 180)
                .background(Color(colorScheme == .dark
                                  ? .secondarySystemBackground
                                  : .systemBackground))
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark
                        ? Color(.clear)
                        : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                
                Spacer()
            }
            .navigationBarTitle("Yearly Summary")
        }
    }
}

struct ProfitByYear_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByYear(viewModel: SessionsListViewModel(), pbyViewModel: ProfitByYearViewModel())
    }
}
