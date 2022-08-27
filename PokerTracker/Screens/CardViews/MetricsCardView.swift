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
    let width = UIScreen.main.bounds.width * 0.8
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            VStack (alignment: .leading) {
                                
                CustomChartView(viewModel: viewModel, data: viewModel.chartCoordinates(), background: false)
                    .overlay(Rectangle().frame(width: nil, height: 0.1, alignment: .bottom).foregroundColor(Color.gray.opacity(0.4)), alignment: .bottom)
                
                Spacer()
                
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Metrics & Analytics")
                            .font(.title3)
                        
                        Text("Study key metrics & analysis on your play, and find ways to improve.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    .padding()
                    .padding(.top, -8)
                }
                
                Spacer()
            }
            
            Text("My Bankroll")
                .font(.title3)
                .offset(y: -145)
                .padding()
        }
        .frame(width: width, height: 360)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.23),
                radius: 12, x: 0, y: 5)
    }
}

struct MetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsCardView().environmentObject(SessionsListViewModel())
    }
}
