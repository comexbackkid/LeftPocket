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
    
    let width = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading) {
                
                Spacer()
         
                BankrollLineChart(showTitle: false, showYAxis: true, showRangeSelector: false, overlayAnnotation: false)
                    .padding(.top, 25)
                    .padding(.horizontal, 20)
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Bankroll & Metrics")
                            .headlineStyle()
                        
                        Text("Tap to view your bankroll progress, player metrics, analytics, & reports.")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .padding(.bottom, 10)
                    }
                    .padding()
                    .dynamicTypeSize(...DynamicTypeSize.large)
                    
                    Spacer()
                }
            }
        }
        .frame(width: width, height: 350)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.5 : 1.0))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

struct MetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsCardView().environmentObject(SessionsListViewModel())
    }
}
