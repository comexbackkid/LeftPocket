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
                
                if viewModel.sessions.isEmpty {
                    EmptyState()
                } else {
                    
                    List {
                        ForEach(viewModel.locations, id: \.self) { location in
                            HStack {
                                Text(location.name)
                                
                                Spacer()
                                
                                let total = viewModel.profitByLocation(location.name)
                                
                                Text(total.accountingStyle())
                                    .fontWeight(total != 0 ? .bold : .none)
                                    .modifier(AccountingView(total: total))
                            }
                        }
                        .navigationBarTitle(Text("Profit by Location"))
                    }
                    .listStyle(InsetListStyle())
                }
            }
        }
    }
}

struct ProfitByLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByLocationView(viewModel: SessionsListViewModel())
    }
}
