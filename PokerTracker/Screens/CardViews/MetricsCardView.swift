//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct MetricsCardView: View {
    var body: some View {
        
        
        ZStack (alignment: .leading) {
            VStack {
                Image("fake-chart-1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Poker Analytics")
                            .font(.title3)
                            .bold()
                        
                        Text("See how you're playing and discover ways to improve.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                Spacer()
            }
            Text("Metrics")
                .fontWeight(.bold)
                .font(.system(size: 30, design: .rounded))
                .foregroundColor(Color("brandBlack"))
                .offset(y: -165)
                .padding()
          
        }
        .frame(width: 350, height: 380)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color(.lightGray).opacity(0.7), radius: 18, x: 0, y: 5)
    }
}

struct MetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsCardView()
    }
}
