//
//  MonthlyReportView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct ProfitByMonth: View {
    
    @State var yearSelection: String
    @State private var profitable = false
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        // Array of [PokerSession] filtered by the yearSelection binding
        let sortedMonths = viewModel.sessions.filter({ $0.date.getYear() == yearSelection })
        let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
        
            List {
                ForEach(viewModel.months, id: \.self) { month in
                    HStack {
                        Text(month)
                        
                        Spacer()
                        
                        let total = sortedMonths.filter({ $0.date.getMonth() == month }).map {$0.profit}.reduce(0,+)
                        
                        Text(total.accountingStyle())
                            .fontWeight(total != 0 ? .bold : .none)
                            .modifier(AccountingView(total: total))
                    }
                }
            }
            .navigationBarTitle(Text("Profit by Month"))
            .navigationBarItems(trailing: Picker(selection: $yearSelection, label: Text(""), content: {
                
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
        ProfitByMonth(yearSelection: "2021", viewModel: SessionsListViewModel())
    }
}
