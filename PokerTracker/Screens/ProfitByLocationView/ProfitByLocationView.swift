//
//  ProfitByLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/6/21.
//

import SwiftUI

struct ProfitByLocationView: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ZStack {
            VStack {
                List {
                    ForEach(viewModel.uniqueLocations, id: \.self) { location in
                        HStack {
                            Text(location)
                            
                            Spacer()
                            
                            let total = viewModel.profitByLocation(location)
                            
                            Text("\(total.accountingStyle())")
                                .bold()
                                .modifier(AccountingView(total: total))
                        }
                    }
                    .navigationBarTitle(Text("Profit by Location"))
                }
                .listStyle(InsetListStyle())
            }
            if viewModel.sessions.isEmpty {
                EmptyState()
            }
        }
    }
}

struct ProfitByLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByLocationView(viewModel: SessionsListViewModel())
    }
}
