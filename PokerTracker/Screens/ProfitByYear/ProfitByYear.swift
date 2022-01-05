//
//  ProfitByYear.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/4/22.
//

import SwiftUI

struct ProfitByYear: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var yearSelection: String = "2021"
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
        
        VStack {
            CustomChartView(data: viewModel.yearlyChartCoordinates(year: yearSelection))
                .frame(height: 280)
            
            Picker(selection: $yearSelection, label: Text("Label"), content: {
                ForEach(allYears, id: \.self) { year in
                    Text(year)
                }
            })
                .pickerStyle(SegmentedPickerStyle())
                .padding(30)
                .padding(.bottom)
            
            VStack (spacing: 10) {
                Spacer()
                HStack {
                    Text("Net Profit")
                    Spacer()
                    Text("\(viewModel.bankrollByYear(year: yearSelection).accountingStyle())")
                        .modifier(AccountingView(total: viewModel.bankrollByYear(year: yearSelection)))
                }
                HStack {
                    Text("Hourly Rate")
                    Spacer()
                    Text("\(viewModel.hourlyByYear(year: yearSelection).accountingStyle())")
                        .modifier(AccountingView(total: viewModel.hourlyByYear(year: yearSelection)))
                }
                
                HStack {
                    Text("Profit Per Session")
                    Spacer()
                    Text("\(viewModel.avgProfitByYear(year: yearSelection).accountingStyle())")
                        .modifier(AccountingView(total: viewModel.avgProfitByYear(year: yearSelection)))
                }
                
                HStack {
                    Text("Total Hours")
                    Spacer()
                    Text("\(viewModel.hoursPlayedByYear(year: yearSelection))")
                }
                Spacer()
                
            }
            .padding(30)
            .frame(width: 340, height: 220)
            .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.3),
                    radius: 12, x: 0, y: 5)
            
            Spacer()
        }
    }
}

struct ProfitByYear_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByYear(yearSelection: "2021", viewModel: SessionsListViewModel())
    }
}
