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
                            HStack (spacing: 0) {
                                Text(location.name)
                                    .font(.callout)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                let total = viewModel.profitByLocation(location.name)
                                let hourlyRate = viewModel.hourlyByLocation(venue: location.name, total: total)
                                
                                Text(hourlyRate.accountingStyle() + " / hr")
                                    .font(.callout)
                                    .profitColor(total: hourlyRate)
                                
                                Text(total.accountingStyle())
                                    .font(.callout)
                                    .profitColor(total: hourlyRate)
                                    .frame(width: 80, alignment: .trailing)
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
