//
//  RingCharts.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/16/24.
//

import SwiftUI

struct RingCharts: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    @Binding var yearFilter: String
    
    var body: some View {
        
        let locations = viewModel.sessions.filter({ $0.profit > 0 && $0.date.getYear() == yearFilter }).map { $0.location }.uniqued()
        
        VStack {
            
            HStack {
                Text("Top Location Win Rates")
                    .cardTitleStyle()
                
                Spacer()
            }
            
            HStack (alignment: .top, spacing: 10) {
                
                // Only display the top 3 locations otherwise it's too messy
                ForEach(locations.prefix(3), id: \.self) { location in
                    RingChart(viewModel: viewModel, location: location, yearFilter: $yearFilter)
                }
            }
            .padding(.top)
            .padding(.bottom, 10)
        }
        
    }
}

struct RingChart: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    let location: LocationModel
    
    @State private var winRate: Float = 0.0
    @Binding var yearFilter: String
    
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
            }
            
            Text("\(location.name)")
                .captionStyle()
                .padding(.top, 10)
        }
        .frame(maxWidth: 100)
        .onAppear {
            locationWinRate(location: location, year: yearFilter)
        }
        .onChange(of: yearFilter, perform: { value in
            locationWinRate(location: location, year: yearFilter)
        })
    }
    
    private func locationWinRate(location: LocationModel, year: String) {
       
        // Need to input the location, and get back that location's number of profitable sessions
        let profitableVisits = viewModel.sessions.filter({ $0.location == location && $0.date.getYear() == year }).filter({ $0.profit > 0 }).count
        
        // Need to capture the total number of times played at that location
        let totalVisits = viewModel.sessions.filter({ $0.location == location && $0.date.getYear() == year }).count
        
        // Divide # of profitable sessions there, by total number of times played at that location
        let locationWinRate = Float(profitableVisits) / Float(totalVisits)
        
        winRate = locationWinRate
    }
}

#Preview {
    RingCharts(viewModel: SessionsListViewModel(), yearFilter: .constant("2024"))
        .padding(.horizontal, 30)
}
