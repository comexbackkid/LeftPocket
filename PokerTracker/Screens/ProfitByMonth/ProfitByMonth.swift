//
//  MonthlyReportView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct ProfitByMonth: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.months, id: \.self) { month in
                    HStack {
                        Text(month)
                        
                        Spacer()
                        
                        let total = viewModel.profitByMonth(month)
                        
                        Text("\(total.accountingStyle())")
                            .bold()
                            .modifier(AccountingView(total: total))
                    }
                }
                .navigationBarTitle(Text("Profit by Month"))
            }
            .listStyle(InsetListStyle())
        }
    }
}

struct MonthlyReportView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByMonth(viewModel: SessionsListViewModel())
    }
}
