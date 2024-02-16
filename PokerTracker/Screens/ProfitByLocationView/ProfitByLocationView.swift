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
                    
                    EmptyState(image: .locations)
                    
                } else {
                    
                    List {
                        
                        ForEach(viewModel.locations, id: \.self) { location in
                            HStack (spacing: 0) {
                                Text(location.name)
                                    .calloutStyle()
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                let total = viewModel.profitByLocation(location.name)
                                let hourlyRate = viewModel.hourlyByLocation(venue: location.name, total: total)
                                
                                Text(hourlyRate.asCurrency() + " / hr")
                                    .font(.callout)
                                    .profitColor(total: hourlyRate)
                                
                                Text(total.asCurrency())
                                    .font(.callout)
                                    .profitColor(total: hourlyRate)
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
