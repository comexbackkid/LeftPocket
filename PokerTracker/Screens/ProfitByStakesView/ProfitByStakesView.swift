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
                                .calloutStyle()

                            Spacer()

                            let total = viewModel.profitByStakes(stakes)
                            let hourlyRate = viewModel.hourlyByStakes(stakes: stakes, total: total)
                            
                            Text(hourlyRate.asCurrency() + " / hr")
                                .font(.callout)
                                .profitColor(total: hourlyRate)

                            Text(total.asCurrency())
                                .font(.callout)
                                .profitColor(total: total)
                                .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.vertical, 10)
                        .listRowBackground(Color.brandBackground)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle(Text("Profit by Stakes"))
                }
                .listStyle(PlainListStyle())
                .background(Color.brandBackground)
                
            }
            
            if viewModel.sessions.isEmpty {
                EmptyState(image: .sessions)
            }
        }
    }
}

struct ProfitByStakesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByStakesView(viewModel: SessionsListViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
