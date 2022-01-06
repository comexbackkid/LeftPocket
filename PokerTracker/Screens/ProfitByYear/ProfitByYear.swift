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
        
        ScrollView {
            VStack {
                ZStack {
                    
                    // We're saying if the yearSelection doesn't equal *this* year, then display data for all years
                    if !pbyViewModel.isLoading {
                        CustomChartView(data: pbyViewModel.timeline == "All"
                                        ? viewModel.chartCoordinates()
                                        : viewModel.yearlyChartCoordinates(year: pbyViewModel.timeline))
                            .frame(height: 280)
                            .clipped()
                        
                    } else {
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                    }
                }
                .frame(height: 280)
                
                CustomSegmentedPicker(pbyViewModel: pbyViewModel)
                    .padding(.bottom, 25)
                    .padding(.top)
                
                VStack (spacing: 15) {
                    Spacer()
                    HStack {
                        Text("Net Profit")
                        Spacer()
                        Text(pbyViewModel.timeline == "All"
                             ? "\(viewModel.tallyBankroll().accountingStyle())"
                             : "\(viewModel.bankrollByYear(year: pbyViewModel.timeline).accountingStyle())")
                            .bold()
                            .modifier(AccountingView(total: pbyViewModel.timeline == "All"
                                                     ? viewModel.tallyBankroll()
                                                     : viewModel.bankrollByYear(year: pbyViewModel.timeline)))
                        
                    }
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        Text(pbyViewModel.timeline == "All"
                             ? "\(viewModel.hourlyRate().accountingStyle())"
                             : "\(viewModel.hourlyByYear(year: pbyViewModel.timeline).accountingStyle())")
                            .bold()
                            .modifier(AccountingView(total: pbyViewModel.timeline == "All"
                                                     ? viewModel.hourlyRate()
                                                     : viewModel.hourlyByYear(year: pbyViewModel.timeline)))
                    }
                    
                    HStack {
                        Text("Profit Per Session")
                        Spacer()
                        Text(pbyViewModel.timeline == "All"
                             ? "\(viewModel.avgProfit().accountingStyle())"
                             : "\(viewModel.avgProfitByYear(year: pbyViewModel.timeline).accountingStyle())")
                            .bold()
                            .modifier(AccountingView(total: pbyViewModel.timeline == "All"
                                                     ? viewModel.avgProfit()
                                                     : viewModel.avgProfitByYear(year: pbyViewModel.timeline)))
                    }
                    
                    HStack {
                        Text("Total Hours")
                        Spacer()
                        Text(pbyViewModel.timeline == "All"
                             ? "\(viewModel.totalHoursPlayed())"
                             : "\(viewModel.hoursPlayedByYear(year: pbyViewModel.timeline))")
                    }
                    Spacer()
                    
                }
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
