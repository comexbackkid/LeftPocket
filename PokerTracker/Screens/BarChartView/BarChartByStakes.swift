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
    
    @Binding var yearFilter: String
    
    let showTitle: Bool
    
    var body: some View {
        
        VStack {
            
            let filteredSessions = viewModel.sessions.filter({ $0.date.getYear() == yearFilter && $0.isTournament != true })
            
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
                    BarMark(x: .value("Total", session.profit) , y: .value("Stakes", session.stakes), width: .ratio(0.4))
                        .foregroundStyle(.teal)
                        .cornerRadius(25)
                }
            }
            .padding(.horizontal, 25)
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
        }
    }
}

#Preview {
    BarChartByStakes(viewModel: SessionsListViewModel(), yearFilter: .constant("2024") ,showTitle: true)
        .preferredColorScheme(.dark)
        .padding()
        .frame(width: 340, height: 300)
}
