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
                                .font(.callout)

                            Spacer()

                            let total = viewModel.profitByStakes(stakes)
                            let hourlyRate = viewModel.hourlyByStakes(stakes: stakes, total: total)
                            
                            Text(hourlyRate.accountingStyle() + " / hr")
                                .font(.callout)
                                .profitColor(total: hourlyRate)

                            Text(total.accountingStyle())
                                .font(.callout)
                                .profitColor(total: total)
                                .frame(width: 80, alignment: .trailing)
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
