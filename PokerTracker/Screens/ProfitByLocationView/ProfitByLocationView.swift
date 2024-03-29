//
//  ProfitByLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/6/21.
//

import SwiftUI

struct ProfitByLocationView: View {
    
    @State private var yearFilter: String = Date().getYear()
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ZStack {
            VStack {
                
                if viewModel.sessions.isEmpty {
                    
                    EmptyState(image: .locations)
                    
                } else {
                    
                    // Array of [PokerSession] filtered by the yearSelection binding
                    let filteredByYear = viewModel.sessions.filter({ $0.date.getYear() == yearFilter })
                    let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
                    
                    List {
                        
                        ForEach(viewModel.locations, id: \.self) { location in
                            HStack (spacing: 0) {
                                Text(location.name)
                                    .calloutStyle()
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                // Still won't grab data if Sessions are imported from a CSV
                                let total = filteredByYear.filter({ $0.location.name == location.name }).map({ $0.profit }).reduce(0,+)
                                let hourlyRate = filteredByYear.filter({ $0.location.name == location.name }).map({ $0.hourlyRate }).reduce(0,+)
                                
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
                        .navigationBarTitle(Text("Location Statistics"))
                    }
                    .padding(.bottom, 50)
                    .listStyle(PlainListStyle())
                    .background(Color.brandBackground)
                    .toolbar {
                        Picker("Picker", selection: $yearFilter) {
                            ForEach(allYears, id: \.self) { year in
                                Text(year)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ProfitByLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByLocationView(viewModel: SessionsListViewModel())
                .preferredColorScheme(.dark)
        }
        
    }
}
