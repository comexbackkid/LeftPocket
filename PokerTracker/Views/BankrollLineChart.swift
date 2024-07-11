
//  SwiftChartsPractice.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/22.
//

import SwiftUI
import Charts

struct BankrollLineChart: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0.0
    @State private var showChart: Bool = false
    @State private var sessionFilter: SessionFilter = .all
    @State private var chartRange: RangeSelection = .all
    
    // Optional year selector, only used in Annual Report View. Overrides dateRange if used
    var yearSelection: [PokerSession]?
    
    var dateRange: [PokerSession] {
        switch chartRange {
        case .all: return viewModel.sessions
        case .oneMonth: return viewModel.filterSessionsLastMonth()
        case .sixMonth: return viewModel.filterSessionsLastSixMonths()
        case .oneYear: return viewModel.filterSessionsLastTwelveMonths()
        case .ytd: return viewModel.filterSessionsYTD()
        }
    }
    var profitAnnotation: Int? {
        
        getProfitForIndex(index: selectedIndex ?? 0, cumulativeProfits: convertedData)
    }
    var convertedData: [Int] {
        
        // Start with zero as our initial data point so chart doesn't look goofy
        var originalDataPoint = [0]
        let newDataPoints = viewModel.calculateCumulativeProfit(sessions: yearSelection != nil ? yearSelection! : dateRange, sessionFilter: sessionFilter)
        originalDataPoint += newDataPoints
        return originalDataPoint
    }
    
    let showTitle: Bool
    let showYAxis: Bool
    let showRangeSelector: Bool
    let overlayAnnotation: Bool

    var body: some View {
        
        VStack {
            
            if showTitle {
                
                HStack {
                    Text("My Bankroll")
                        .cardTitleStyle()
                    
                    Spacer()
                    
                    fullScreenToggleButton
                    
                    filterButton
                }
                .padding(.bottom, 40)
            }
            
            // Annotations not available pre-iOS 17. Display plain chart if so.
            if #available(iOS 17.0, *) {
                lineChart
                
            } else { lineChartOldVersion }
            
            if showRangeSelector { rangeSelector }
            
        }
    }
    
    @available(iOS 17.0, *)
    var lineChart: some View {
        
        VStack {
            
            let cumulativeProfitArray = viewModel.calculateCumulativeProfit(sessions: yearSelection != nil ? yearSelection! : dateRange, sessionFilter: sessionFilter)
            
            Chart {
                
                ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .opacity(showChart ? 1.0 : 0.0)
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [sessionFilter != .tournaments ? Color("lightBlue") : .donutChartOrange, .clear], startPoint: .top, endPoint: .bottom))
                        .opacity(showChart ? 0.18 : 0.0)
                    
                    if let selectedIndex {
                        
                        PointMark(x: .value("Point", selectedIndex), y: .value("Profit", profitAnnotation ?? 0))
                            .foregroundStyle(Color.brandWhite)
                    }
                }
                .foregroundStyle(LinearGradient(colors: [sessionFilter != .tournaments ? .chartAccent : .donutChartOrange,
                                                         sessionFilter != .tournaments ? .chartBase : .orange],
                                                startPoint: .topTrailing, endPoint: .bottomLeading))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                if let selectedIndex {
                    
                    RuleMark(x: .value("Selected Date", selectedIndex))
                        .lineStyle(StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundStyle(.gray.opacity(0.2))
                        .annotation(position: overlayAnnotation
                                    ?  (selectedIndex == 0 && convertedData.count == 2)
                                    || ((0...1).contains(selectedIndex) && convertedData.count > 2)
                                    || ((0...6).contains(selectedIndex) && convertedData.count > 8)
                                    || ((0...18).contains(selectedIndex) && convertedData.count > 25)
                                    || ((0...30).contains(selectedIndex) && convertedData.count > 50)
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
            .overlay {
                if cumulativeProfitArray.isEmpty {
                    VStack {
                        Text("No chart data to display.")
                            .calloutStyle()
                            .foregroundStyle(.secondary)
                    }
                    .offset(y: -20)
                }
            }
        }
    }
    
    var lineChartOldVersion: some View {
        
        VStack {
            
            let cumulativeProfitArray = viewModel.calculateCumulativeProfit(sessions: yearSelection != nil ? yearSelection! : dateRange, sessionFilter: sessionFilter)
            
            Chart {
                
                ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .opacity(showChart ? 1.0 : 0.0)
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [sessionFilter != .tournaments ? Color("lightBlue") : .donutChartGreen, .clear], startPoint: .top, endPoint: .bottom))
                        .opacity(showChart ? 0.2 : 0.0)
                }
                .foregroundStyle(LinearGradient(colors: [sessionFilter != .tournaments ? .chartAccent : .donutChartGreen,
                                                         sessionFilter != .tournaments ? .chartBase : .donutChartDarkBlue],
                                                startPoint: .topTrailing, endPoint: .bottomLeading))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
            .onAppear {
                withAnimation {
                    showChart = true
                }
            }
            .animation(.easeIn(duration: 1.2), value: showChart)
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
            .overlay {
                if cumulativeProfitArray.isEmpty {
                    VStack {
                        Text("No chart data to display.")
                            .calloutStyle()
                            .foregroundStyle(.secondary)
                    }
                    .offset(y: -20)
                }
            }
        }
    }
    
    var fullScreenToggleButton: some View {
        
        Button {
            viewModel.lineChartFullScreen.toggle()
        } label: {
            Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
        }
        .tint(.brandPrimary)
        .padding(.horizontal, 5)
        
    }
    
    var filterButton: some View {
        
        Menu {
            Picker("", selection: $sessionFilter) {
                ForEach(SessionFilter.allCases, id: \.self) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
        } label: {
            Text(sessionFilter.rawValue.capitalized + " ›")
                .bodyStyle()
        }
        .tint(.brandPrimary)
        .transaction { transaction in
            transaction.animation = nil
        }
        
    }
    
    var rangeSelector: some View {
        
        HStack (spacing: 17) {
            
            ForEach(RangeSelection.allCases, id: \.self) { range in
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    chartRange = range
                } label: {
                    Text("\(range.displayName)")
                        .bodyStyle()
                        .fontWeight(chartRange == range ? .black : .regular)
                }
                .tint(chartRange == range ? .primary : .brandPrimary)
            }
            
            Spacer()
        }
        .padding(.top, 20)
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
        BankrollLineChart(showTitle: true, showYAxis: true, showRangeSelector: true, overlayAnnotation: true)
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
            .frame(height: 350)
            .padding()
    }
}
