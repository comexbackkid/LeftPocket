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
                                
                CustomChartView(data: viewModel.chartCoordinates())
                    .frame(width: 340, height: 240)
                    .clipped()
                
                Spacer()
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        Text("My Metrics")
                            .font(.title3)
                            .bold()
                        Text("Gather valuable insights into your game and find ways to improve it.")
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
            
            Text("Total Profit")
                .bold()
                .font(.title)
                .offset(y: -145)
                .padding()
        }
        .frame(width: 340, height: 360)
        .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
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
