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
                            Text("$" + "\(viewModel.sessions.filter({$0.location == location}).reduce(0) { $0 + $1.profit})")
                                .bold()
                                .foregroundColor(viewModel.sessions.filter({$0.location == location}).reduce(0) { $0 + $1.profit} > 0 ? .green : viewModel.sessions.filter({$0.location == location}).reduce(0) { $0 + $1.profit} < 0 ? .red : Color(.systemGray))
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
