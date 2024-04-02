//
//  ProfitByGameView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/12/21.
//

import SwiftUI

struct ProfitByStakesView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var yearFilter = Date().getYear()

    @ObservedObject var viewModel: SessionsListViewModel

    var body: some View {

        ScrollView {
            
            ZStack {
                VStack {
                    
                    VStack (spacing: 10) {
                        
                        headerInfo
                        
                        Divider()
                            .padding(.bottom, 10)
                        
                        stakesTotals
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle(Text("Game Stakes"))
                    .padding(30)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
                    .cornerRadius(20)
                    .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                    .padding(.top, 50)
                    
                    yearTotal
                   
                    HStack {
                        Spacer()
                    }
                }
                
                if viewModel.sessions.filter({ $0.isTournament == false }).isEmpty {
                    EmptyState(image: .sessions)
                }
            }
        }
        .background(Color.brandBackground)
    }
    
    var headerInfo: some View {
        
        VStack (spacing: 7) {
            
            HStack {
                Text("Select Year")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
                
                Menu {
                    Picker("", selection: $yearFilter) {
                        ForEach(allYears, id: \.self) {
                            Text($0)
                        }
                    }
                } label: {
                    Text(yearFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
            }
            
            HStack {
                Text("Total Sessions")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Text("\(viewModel.sessions.filter({ $0.date.getYear() == yearFilter }).count)")
                    .bodyStyle()
            }
        }
        .padding(.bottom, 10)
    }
    
    var stakesTotals: some View {
        
        ForEach(viewModel.uniqueStakes, id: \.self) { stakes in
            
            HStack {
                Text(stakes)
                    .font(.custom("Asap-Regular", size: 18, relativeTo: .body))

                Spacer()

                let total = viewModel.profitByStakes(stakes, year: yearFilter)
//                                let hourlyRate = viewModel.hourlyByStakes(stakes: stakes, total: total)
                
//                                Text("\(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))) / hr")
//                                    .font(.callout)
//                                    .profitColor(total: hourlyRate)

                Text(total, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                    .profitColor(total: total)
                    .frame(width: 80, alignment: .trailing)
            }
        }
    }
    
    var yearTotal: some View {
        
        VStack {
            
            let bankrollTotalByYear = viewModel.bankrollByYear(year: yearFilter)
            
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color(.systemGray))
                
                Text("Total")
                    
                Spacer()
                
                Text(bankrollTotalByYear, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bankrollTotalByYear)
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        .padding(.top, 15)
        
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
