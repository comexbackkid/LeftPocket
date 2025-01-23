//
//  BarChartByStakes.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/11/24.
//

import SwiftUI
import Charts

struct BarChartByStakes: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    let showTitle: Bool
    let filteredSessions: [PokerSession]
    
    var body: some View {
        
        VStack {
            
            let stakesList = Set(viewModel.allCashSessions().map { $0.stakes })
            let stakesCount = stakesList.count
            let baseHeight: CGFloat = 50
            let minHeight: CGFloat = 150
            
            // Calculate the height based on the number of stakes, ensuring a minimum height
            let chartHeight = max(minHeight, CGFloat(stakesCount) * baseHeight)
            
            if showTitle {
                HStack {
                    Text("Profit By Stakes")
                        .cardTitleStyle()
                    
                    Spacer()
                    
                }
                .padding(.bottom, 20)
            }
            
            Chart {
                ForEach(filteredSessions, id: \.self) { session in
                    BarMark(x: .value("Total", session.profit) , y: .value("Stakes", session.stakes), height: 20.0)
                        .foregroundStyle(.teal)
                        .cornerRadius(25)
                }
            }
            .padding(.horizontal, 15)
            .frame(height: chartHeight)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel(centered: true, anchor: .trailing, horizontalSpacing: 15, verticalSpacing: 20)
                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                }
            }
            .chartXAxis {
                AxisMarks() { value in
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.axisShortHand(viewModel.userCurrency))
                                .captionStyle()
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [0]))
                        .foregroundStyle(.gray.opacity(0.25))
                    
                }
            }
            .padding(.leading, 25)
        }
    }
}

#Preview {
    BarChartByStakes(viewModel: SessionsListViewModel(), showTitle: true, filteredSessions: [MockData.sampleSession])
}
