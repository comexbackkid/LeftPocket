//
//  BarChartByLocation.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/11/24.
//

import SwiftUI
import Charts

struct BarChartByLocation: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    let showTitle: Bool
    
    var body: some View {
        
        VStack {
            
            if showTitle {
                HStack {
                    Text("Profit By Location")
                        .cardTitleStyle()
                    
                    Spacer()
                    
                }
                .padding(.bottom, 40)
            }
            
            stakesChart

        }
    }
    
    var barChart: some View {
        
        Chart {
            
            ForEach(viewModel.sessions, id: \.self) { session in
                
                BarMark(x: .value("Location", session.location.name), y: .value("Profit", session.profit), width: 20)
                    .cornerRadius(25)
                    .foregroundStyle(by: .value("Location", session.location.name))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks() { value in
                AxisGridLine()
                    .foregroundStyle(.opacity(0.2))
                AxisValueLabel() {
                    if let intValue = value.as(Int.self) {
                        Text(intValue.axisShortHand(viewModel.userCurrency))
                            .captionStyle()
                            .padding(.leading)
                    }
                }
            }
        }
        .chartLegend(spacing: 25)
        .chartForegroundStyleScale([
            viewModel.locations[0].name: .mint,
            viewModel.locations[1].name: .mint.opacity(0.8),
            viewModel.locations[2].name: .mint.opacity(0.5),
            viewModel.locations[3].name: .mint.opacity(0.2),
            ])
    }
    
    var stakesChart: some View {
        
        Chart {
            ForEach(viewModel.sessions, id: \.self) { session in
                BarMark(x: .value("Stakes", session.stakes), y: .value("Total", session.profit), width: 20)
                    .foregroundStyle(.mint)
                    .cornerRadius(25)
            }
        }
        .chartXAxis {
            AxisMarks() { value  in
                AxisValueLabel()
            }
        }
    }
}

#Preview {
    BarChartByLocation(showTitle: true)
        .padding()
        .frame(width: 340, height: 340)
        .environmentObject(SessionsListViewModel())
}
