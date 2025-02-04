//
//  RingCharts.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/16/24.
//

import SwiftUI

struct RingCharts: View {
    
    let sessions: [PokerSession_v2]
    
    var body: some View {
        
        let locationCounts = Dictionary(grouping: sessions, by: { $0.location.name }).mapValues { $0.count }
        let topLocations = locationCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        VStack {
            
            HStack {
                Text("Top Location Win Ratio")
                    .cardTitleStyle()
                
                Spacer()
            }
            
            HStack (alignment: .top, spacing: 10) {
                ForEach(topLocations, id: \.self) { location in
                    RingChart(location: location, sessions: sessions)
                }
            }
            .padding(.top)
            .padding(.bottom, 10)
        }
    }
}

struct RingChart: View {
    
    let location: String
    let sessions: [PokerSession_v2]
    
    @State private var winRate: Float = 0.0
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                Circle()
                    .stroke(lineWidth: 8)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray.opacity(0.1))
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(winRate, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(LinearGradient(colors: [.mint, .mint.opacity(0.5)],
                                                    startPoint: .leading,
                                                    endPoint: .bottom))
                    .animation(.easeInOut(duration: 2.0), value: winRate)
                
                Text("\(winRate.asPercent())")
                    .captionStyle()
                    .dynamicTypeSize(...DynamicTypeSize.medium)
            }
            
            Text("\(location)")
                .captionStyle()
                .padding(.top, 10)
                .lineLimit(2)
        }
        .frame(maxWidth: 100)
        .onAppear { locationWinRate(location: location, sessions: sessions) }
        .onChange(of: sessions, perform: { value in
            locationWinRate(location: location, sessions: value)
        })
    }
    
    private func locationWinRate(location: String, sessions: [PokerSession_v2]) {
        var profitableVisits = 0
        var totalVisits = 0
        
        for session in sessions where session.location.name == location {
            totalVisits += 1
            if session.profit > 0 {
                profitableVisits += 1
            }
        }
        
        let locationWinRate = totalVisits > 0 ? Float(profitableVisits) / Float(totalVisits) : 0
        
        winRate = locationWinRate
    }
}

#Preview {
    RingCharts(sessions: MockData.allSessions)
        .padding(.horizontal, 30)
}
