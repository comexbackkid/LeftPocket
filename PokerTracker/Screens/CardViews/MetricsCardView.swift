//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct MetricsCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    let width = UIScreen.main.bounds.width * 0.9
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading) {
                
                Spacer()
                                
                CustomChartView(viewModel: viewModel, data: viewModel.chartCoordinates(), background: true)
//                    .frame(height: 250)
                
//                Divider()
                
//                Spacer()
                
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Bankroll & Metrics")
                            .headlineStyle()
                        
                        Text("View your current bankroll, advanced metrics, analytics, & reports.")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .padding(.bottom, 10)
                    }
                    .padding()
//                    .padding(.top, -8)
                }
                
//                Spacer()
            }
            
//            VStack {
//                Text("My Bankroll")
//                    .signInTitleStyle()
//                    .fontWeight(.heavy)
//                    .padding()
////                    .offset(y: -145)
//                
//                Spacer()
//                
//            }
        }
        .frame(width: width, height: 390)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
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
