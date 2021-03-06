//
//  EmptyStateMetricsBankroll.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct EmptyStateMetricsBankroll: View {
    var body: some View {
        
            VStack (alignment: .center, spacing: 5) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .frame(width: 80)
                    .padding(.bottom)
                
                Text("No Data to Chart")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Add some sessions so you can begin tracking your bankroll growth!")
                    .frame(width: 300)
                    .opacity(0.7)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
            }
    }
}

struct EmptyStateMetricsBankroll_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateMetricsBankroll()
    }
}
