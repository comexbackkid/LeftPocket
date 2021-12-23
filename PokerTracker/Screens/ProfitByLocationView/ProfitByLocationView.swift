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
//                        HStack (spacing: 0) {
//                            Text("Location")
//                                .bold()
//                            Spacer()
//                            VStack (alignment: .trailing) {
//                                Text("Hourly")
//                                    .bold()
//                            }
//                            VStack {
//                                Text("Total")
//                                    .bold()
//                            }
//                            .frame(width: UIScreen.main.bounds.width / 5.5, alignment: .trailing)
//                        }
                        
                        ForEach(viewModel.locations, id: \.self) { location in
                            HStack (spacing: 0) {
                                Text(location.name)
                                    .font(.callout)
                                
                                Spacer()
                                
                                let total = viewModel.profitByLocation(location.name)
                                
//                                VStack (alignment: .trailing) {
//                                    Text("$45")
//                                        .font(.callout)
//                                }
                                
                                VStack {
                                    Text(total.accountingStyle())
                                        .font(.callout)
                                        .fontWeight(total != 0 ? .bold : .none)
                                        .modifier(AccountingView(total: total))
                                    
                                }
//                                .frame(width: UIScreen.main.bounds.width / 5.5, alignment: .trailing)
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
