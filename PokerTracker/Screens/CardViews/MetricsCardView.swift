//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI
import SwiftUICharts

struct MetricsCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            VStack (alignment: .leading) {
                                
                CustomChartView(viewModel: viewModel, data: viewModel.chartCoordinates(), background: false)
                    .frame(width: 340, height: 240)
                
                Spacer()
                
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Metrics & Analytics")
                            .font(.title3)
                            .bold()
                        Text("Study key metrics & analysis on your play, and find ways to improve.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            .frame(maxWidth: 340)
            
            Text("Bankroll")
                .bold()
                .font(.title)
                .offset(y: -145)
                .padding()
        }
        .frame(width: 340, height: 360)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.3),
                radius: 12, x: 0, y: 5)
    }
}

struct MetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsCardView().environmentObject(SessionsListViewModel())
    }
}
