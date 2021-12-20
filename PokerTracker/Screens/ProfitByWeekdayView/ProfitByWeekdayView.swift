//
//  ProfitByWeekdayView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/8/21.
//

import SwiftUI

struct ProfitByWeekdayView: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        VStack {
            List {
                ForEach (viewModel.daysOfWeek, id: \.self) { day in
                    HStack {
                        Text(day)
                        
                        Spacer()
                        
                        let total = viewModel.profitByDayOfWeek(day)
                        
                        Text("\(total.accountingStyle())")
                            .fontWeight(total != 0 ? .bold : .none)
                            .modifier(AccountingView(total: total))
                    }
                }
                .navigationBarTitle(Text("Profit by Weekday"))
            }
            .listStyle(InsetListStyle())
        }
    }
}

struct ProfitByWeekdayView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByWeekdayView(viewModel: SessionsListViewModel())
    }
}
