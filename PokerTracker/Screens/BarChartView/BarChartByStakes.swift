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
    let filteredSessions: [PokerSession_v2]
    
    var body: some View {
        
        VStack {
            
            let stakesList = Set(viewModel.allCashSessions().map { $0.stakes })
            let stakesProfits = Dictionary(grouping: filteredSessions, by: { $0.stakes })
                .mapValues { sessions in
                    sessions.reduce(0) { $0 + $1.profit }
                }
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
                ForEach(stakesProfits.sorted(by: { $0.value > $1.value }), id: \.key) { stake, totalProfit in
                    BarMark(
                        x: .value("Total Profit", totalProfit),
                        y: .value("Stakes", stake), height: 20.0
                    )
                    .foregroundStyle(totalProfit >= 0 ? .teal : .pink)
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal, 15)
            .frame(height: chartHeight)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel(centered: true, anchor: .trailing, horizontalSpacing: 15, verticalSpacing: 20)
//                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                        .font(.custom("AsapCondensed-Light", size: 12, relativeTo: .caption2))
                }
            }
            .chartXAxis {
                AxisMarks() { value in
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.axisShortHand(viewModel.userCurrency))
//                                .captionStyle()
                                .font(.custom("AsapCondensed-Light", size: 12, relativeTo: .caption2))
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
