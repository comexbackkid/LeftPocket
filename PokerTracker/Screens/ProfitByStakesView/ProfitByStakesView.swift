//
//  ProfitByGameView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/12/21.
//

import SwiftUI

struct ProfitByStakesView: View {

    @ObservedObject var viewModel: SessionsListViewModel

    var body: some View {

        ZStack {
            VStack {
                List {
                    ForEach(viewModel.uniqueStakes, id: \.self) { stakes in
                        HStack {
                            Text(stakes)

                            Spacer()

                            let total = viewModel.profitByStakes(stakes)

                            Text(total.accountingStyle())
                                .bold()
                                .modifier(AccountingView(total: total))
                        }
                    }
                    .navigationBarTitle(Text("Profit by Stakes"))
                }
                .listStyle(InsetListStyle())
            }
            if viewModel.sessions.isEmpty {
                EmptyState()
            }
        }
    }
}

struct ProfitByStakesView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByStakesView(viewModel: SessionsListViewModel())
    }
}
