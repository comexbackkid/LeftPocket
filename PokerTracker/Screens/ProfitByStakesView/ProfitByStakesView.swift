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
                            
                            Text("\(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))) / hr")
                                .font(.callout)
                                .profitColor(total: hourlyRate)

                            Text(total, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
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
            
            if viewModel.sessions.filter({ $0.isTournament == false }).isEmpty {
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
