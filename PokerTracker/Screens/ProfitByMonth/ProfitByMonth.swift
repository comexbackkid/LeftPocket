//
//  MonthlyReportView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct ProfitByMonth: View {
    
    @State private var yearFilter: String = Date().getYear()
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        // Array of [PokerSession] filtered by the yearSelection binding
        let filteredMonths = viewModel.sessions.filter({ $0.date.getYear() == yearFilter })
        let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
        
            List {
                
                ForEach(viewModel.months, id: \.self) { month in
                    HStack {
                        Text(month)
                            .font(.callout)
                        
                        Spacer()
                        
                        let total = filteredMonths.filter({ $0.date.getMonth() == month }).map {$0.profit}.reduce(0,+)
                        let hourlyRate = filteredMonths.filter({ $0.date.getMonth() == month }).map { $0.hourlyRate }.reduce(0,+)
                        
                        Text(hourlyRate.accountingStyle() + " / hr ")
                            .font(.callout)
                            .modifier(AccountingView(total: total))
                        
                        Text(total.accountingStyle())
                            .font(.callout)
                            .modifier(AccountingView(total: total))
                            .frame(width: 80, alignment: .trailing)
                    }
                }
            }
            .navigationBarTitle(Text("Profit by Month"))
            .navigationBarItems(trailing: Picker(selection: $yearFilter, label: Text(""), content: {
                
                ForEach(allYears, id: \.self) { year in
                    Text(year)
                }
            })
            .pickerStyle(MenuPickerStyle()))
            .listStyle(PlainListStyle())
    }
}

struct MonthlyReportView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByMonth(viewModel: SessionsListViewModel())
    }
}
