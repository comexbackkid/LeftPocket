//
//  BankrollLineChartSimple.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/2/25.
//

import SwiftUI
import Charts

struct BankrollLineChartSimple: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    let sessions: [PokerSession_v2]
    private var chartData: [Int] {
        guard !sessions.isEmpty else {
            return [0]
        }
        let raw = viewModel.calculateCumulativeProfit(sessions: sessions, sessionFilter: .all)
        return [0] + raw
    }
    
    var body: some View {
        
        Group {
            
            let lineGradient = LinearGradient(colors: [.chartAccent, .chartBase],
                                              startPoint: .topTrailing,
                                              endPoint: .bottomLeading)
            
            let areaGradient = LinearGradient(colors: [Color("lightBlue").opacity(0.85), Color("lightBlue").opacity(0.25), .clear, .clear],
                                              startPoint: .top,
                                              endPoint: .bottom)
            
            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { idx, val in
                    LineMark(x: .value("Index", idx),y: .value("Profit", val))
                        .foregroundStyle(lineGradient)
                    
                    AreaMark(x: .value("Index", idx), y: .value("Profit", val))
                        .foregroundStyle(areaGradient)
                        .opacity(0.25)
                }
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
            .opacity(chartData.count == 1 ? 0 : 1.0)
            .padding(.vertical, 8)
            .chartXAxis(.hidden)
            .chartYScale(domain: [chartData.min()!, chartData.max()!])
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.axisShortHand(viewModel.userCurrency))
                                .font(.custom("AsapCondensed-Bold", size: 12, relativeTo: .caption2))
                                .padding(.leading, 12)
                        }
                    }
                }
            }
            .overlay {
                if chartData.count == 1 {
                    VStack {
                        Text("No chart data to display.")
                            .calloutStyle()
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
            }
            .allowsHitTesting(viewModel.bankrollLineChartData.isEmpty ? false : true)
        }
    }
}

#Preview {
    BankrollLineChartSimple(sessions: MockData.allSessions)
        .environmentObject(SessionsListViewModel())
        .frame(height: 200)
}
