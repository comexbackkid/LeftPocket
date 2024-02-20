
//  SwiftChartsPractice.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/22.
//

import SwiftUI
import Charts

struct DummySession: Identifiable, Hashable {
    var id = UUID()
    let date: Date
    let profit: Int
}

struct SwiftLineChartsPractice: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0.0
    @State private var showChart: Bool = false
    
    let showTitle: Bool
    let overlayAnnotation: Bool
    let dummyData: [DummySession] = [
        
        DummySession(date: Date.from(year: 2023, month: 1, day: 11), profit: 150),
        DummySession(date: Date.from(year: 2023, month: 1, day: 15), profit: 90),
        DummySession(date: Date.from(year: 2023, month: 2, day: 1), profit: -70),
        DummySession(date: Date.from(year: 2023, month: 3, day: 2), profit: 224),
        DummySession(date: Date.from(year: 2023, month: 3, day: 8), profit: 20),
        DummySession(date: Date.from(year: 2023, month: 4, day: 3), profit: -100),
        DummySession(date: Date.from(year: 2023, month: 4, day: 10), profit: 412),
        DummySession(date: Date.from(year: 2023, month: 4, day: 17), profit: 105),
        DummySession(date: Date.from(year: 2023, month: 5, day: 16), profit: 89),
        DummySession(date: Date.from(year: 2023, month: 6, day: 2), profit: -750),
        DummySession(date: Date.from(year: 2023, month: 6, day: 9), profit: -411),
        DummySession(date: Date.from(year: 2023, month: 6, day: 14), profit: 480),
        DummySession(date: Date.from(year: 2023, month: 6, day: 29), profit: 100),
        DummySession(date: Date.from(year: 2023, month: 8, day: 11), profit: 234),
        DummySession(date: Date.from(year: 2023, month: 8, day: 12), profit: -122),
        DummySession(date: Date.from(year: 2023, month: 9, day: 8), profit: 175),
        DummySession(date: Date.from(year: 2023, month: 11, day: 11), profit: 40),
        DummySession(date: Date.from(year: 2023, month: 12, day: 1), profit: 75),
        DummySession(date: Date.from(year: 2024, month: 1, day: 15), profit: 90),
        DummySession(date: Date.from(year: 2024, month: 2, day: 1), profit: -20),
        DummySession(date: Date.from(year: 2024, month: 3, day: 2), profit: 224),
        DummySession(date: Date.from(year: 2024, month: 3, day: 8), profit: 20),
        DummySession(date: Date.from(year: 2024, month: 4, day: 3), profit: -100),
//        DummySession(date: Date.from(year: 2024, month: 4, day: 10), profit: 412),
//        DummySession(date: Date.from(year: 2024, month: 4, day: 17), profit: 105),
//        DummySession(date: Date.from(year: 2024, month: 5, day: 16), profit: 89),
//        DummySession(date: Date.from(year: 2024, month: 6, day: 2), profit: -75),
//        DummySession(date: Date.from(year: 2024, month: 6, day: 9), profit: -211),
//        DummySession(date: Date.from(year: 2024, month: 6, day: 14), profit: -480),
//        DummySession(date: Date.from(year: 2024, month: 6, day: 29), profit: 100),
//        DummySession(date: Date.from(year: 2024, month: 8, day: 11), profit: 234),
//        DummySession(date: Date.from(year: 2024, month: 8, day: 12), profit: -122),
//        DummySession(date: Date.from(year: 2024, month: 9, day: 8), profit: 175),
//        DummySession(date: Date.from(year: 2024, month: 11, day: 11), profit: 40),
//        DummySession(date: Date.from(year: 2024, month: 12, day: 1), profit: -175),
    ]
    
    var profitAnnotation: Int? {
        
        getProfitForIndex(index: selectedIndex ?? 0, cumulativeProfits: convertedData)
    }
    var convertedData: [Int] {
        
        // Start with zero as our initial data point so chart doesn't look goofy
        var originalDataPoint = [0]
        let newDataPoints = calculateCumulativeProfit2(sessions: viewModel.sessions)
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
                    
                    // Annotation is complicated. Here's how it breaks down if we're choosing to show overlayAnnotation.
                    // If there's over 2 sessions logged, AND we're selecting in the first 3 indices, move the annotation to the trailing side.
                    // Or, if there are over 10 sessions logged, and we're selecting in the first 7 indices, again, move to trailing side.
                    // Otherwise the annotation display overlays our RuleMark and it looks stupid.
                    
                    RuleMark(x: .value("Selected Date", selectedIndex))
                        .lineStyle(StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundStyle(.gray.opacity(0.2))
                        .annotation(position: overlayAnnotation 
                                    ?  ((0...2).contains(selectedIndex) && convertedData.count > 2)
                                    || ((0...6).contains(selectedIndex) && convertedData.count > 10)
                                    || ((0...15).contains(selectedIndex) && convertedData.count > 25)
                                    ?  .trailing : .leading
                                    :  .top,
                                    spacing: overlayAnnotation ? 12 : 8,
                                    overflowResolution: .init(x: .fit(to: .chart))) {
                            Text(profitAnnotation?.asCurrency() ?? "$0")
                                .captionStyle()
                                .padding(10)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                }
            }
            .onAppear {
                showChart = true
            }
            .animation(.easeIn(duration: 1.5), value: showChart)
            .sensoryFeedback(.selection, trigger: selectedIndex)
            .chartXSelection(value: $selectedIndex)
            .chartXAxis(.hidden)
            .chartYScale(domain: [convertedData.min()!, convertedData.max()!])
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(.gray.opacity(0.25))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.axisFormat)
                                .padding(.leading, 25)
                        }
                    }
                }
            }
        }
    }
    
    func calculateCumulativeProfit2(sessions: [PokerSession]) -> [Int] {
        
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
        SwiftLineChartsPractice(showTitle: true, overlayAnnotation: true)
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
            .frame(height: 350)
            .padding()
    }
}
