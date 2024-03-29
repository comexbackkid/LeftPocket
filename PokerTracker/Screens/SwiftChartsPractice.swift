
//  SwiftChartsPractice.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/22.
//

import SwiftUI
import Charts

struct SwiftLineChartsPractice: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0.0
    @State private var showChart: Bool = false
    
    var dateRange: [PokerSession]
    let showTitle: Bool
    let showYAxis: Bool
    let overlayAnnotation: Bool
    
    var profitAnnotation: Int? {
        
        getProfitForIndex(index: selectedIndex ?? 0, cumulativeProfits: convertedData)
    }
    var convertedData: [Int] {
        
        // Start with zero as our initial data point so chart doesn't look goofy
        var originalDataPoint = [0]
        let newDataPoints = calculateCumulativeProfit(sessions: dateRange)
        originalDataPoint += newDataPoints
        return originalDataPoint
    }
    
    var body: some View {
        
        VStack {
            
            if showTitle {
                
                HStack {
                    Text("My Bankroll")
                        .cardTitleStyle()
                    
                    Spacer()
                    
                }
                .padding(.bottom, 40)
            }
            
            Chart {
                
                ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .opacity(showChart ? 1.0 : 0.0)
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [Color("lightBlue"), .clear], startPoint: .top, endPoint: .bottom))
                        .opacity(showChart ? 0.2 : 0.0)
                    
                    if let selectedIndex {
                        
                        PointMark(x: .value("Point", selectedIndex), y: .value("Profit", profitAnnotation ?? 0))
                            .foregroundStyle(Color.brandWhite)
                    }
                }
                .foregroundStyle(LinearGradient(colors: [.chartAccent, .chartBase], startPoint: .topTrailing, endPoint: .bottomLeading))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                if let selectedIndex {
                    
                    RuleMark(x: .value("Selected Date", selectedIndex))
                        .lineStyle(StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundStyle(.gray.opacity(0.2))
                        .annotation(position: overlayAnnotation 
                                    ?  (selectedIndex == 0 && convertedData.count == 2)
                                    || ((0...1).contains(selectedIndex) && convertedData.count > 2)
                                    || ((0...5).contains(selectedIndex) && convertedData.count > 8)
                                    || ((0...15).contains(selectedIndex) && convertedData.count > 25)
                                    ?  .trailing : .leading
                                    :  .top,
                                    spacing: overlayAnnotation ? 12 : 8,
                                    overflowResolution: .init(x: .fit(to: .chart))) {
                            
                            Text(profitAnnotation ?? 0, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                                .captionStyle()
                                .padding(10)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                }
            }
            .onAppear {
                withAnimation {
                    showChart = true
                }
            }
            .animation(.easeIn(duration: 1.2), value: showChart)
            .sensoryFeedback(.selection, trigger: selectedIndex)
            .chartXSelection(value: $selectedIndex)
            .chartXAxis(.hidden)
            .chartYScale(domain: [convertedData.min()!, convertedData.max()!])
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(.gray.opacity(0.25))
                    AxisValueLabel() {
                        if showYAxis {
                            if let intValue = value.as(Int.self) {
                                Text(intValue.axisShortHand(viewModel.userCurrency))
                                    .captionStyle()
                                    .padding(.leading, 25)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func calculateCumulativeProfit(sessions: [PokerSession]) -> [Int] {
        
        // We run this so tha twe can just use the Index as our X Axis value. Keeps spacing uniform and neat looking.
        // Then, in chart configuration we just plot along the Index value, and Int is our cumulative profit amount.
        var cumulativeProfit = 0

        // I'm having to manually sort the sessions array here, even though it's doing it in the Add Session function. Don't know why.
        let result = sessions.sorted(by: { $0.date < $1.date }).map { session -> Int in
            cumulativeProfit += session.profit
            return cumulativeProfit
        }

        return result
    }
    
    func getProfitForIndex(index: Int, cumulativeProfits: [Int]) -> Int? {
        
        guard index >= 0, index < cumulativeProfits.count else {
            
            // Index out of bounds
            return nil
        }

        return cumulativeProfits[index]
    }
}

struct SwiftChartsPractice_Previews: PreviewProvider {
    
    static var previews: some View {
        SwiftLineChartsPractice(dateRange: SessionsListViewModel().sessions, showTitle: true, showYAxis: true, overlayAnnotation: true)
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
            .frame(height: 350)
            .padding()
    }
}
