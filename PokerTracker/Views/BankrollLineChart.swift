
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
    @AppStorage("sessionFilter") private var chartSessionFilter: SessionFilter = .all
    @State private var chartRange: RangeSelection = .all
    
    // Optional year selector, only used in Annual Report View. Overrides dateRange if used
    var yearSelection: [PokerSession]?
    var dateRange: [PokerSession] {
        switch chartRange {
        case .all: return viewModel.sessions
        case .oneMonth: return viewModel.filterSessionsLastMonth()
        case .threeMonth: return viewModel.filterSessionsLastThreeMonths()
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
        let newDataPoints = viewModel.calculateCumulativeProfit(sessions: yearSelection != nil ? yearSelection! : dateRange, sessionFilter: chartSessionFilter)
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
                
                HStack (alignment: .top) {
                    
                    VStack (alignment: .leading, spacing: 3) {
                        Text("Player Profit")
                            .cardTitleStyle()
                        
                        let amountText: Int? = profitAnnotation
                        
                        Group {
                            if let amountText {
                                HStack (spacing: 5) {
                                    if amountText != 0 {
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(amountText > 0 ? .green : .red)
                                            .rotationEffect(.degrees(amountText < 0 ? 90 : 0))
                                            .animation(.default.speed(2), value: amountText)
                                    }
                                    
                                    Text(amountText == 0 ? "No Selection" : "\(amountText.formatted(.currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))))")
                                        .font(.custom("Asap-Medium", size: 17, relativeTo: .caption2))
                                        .foregroundStyle(amountText > 0 ? .green : amountText < 0 ? .red : .secondary)
                                }
                            }
                        }
                        .animation(nil, value: selectedIndex)
                    }
                    
                    Spacer()
                    
                    fullScreenToggleButton
                    
                    filterButton
                }
                .padding(.bottom)
                
                .fullScreenCover(isPresented: $viewModel.lineChartFullScreen, content: {
                    LineChartFullScreen(lineChartFullScreen: $viewModel.lineChartFullScreen)
                    
                })
            }
            
            if #available(iOS 17.0, *) {
                lineChart
                
            } else { lineChartOldVersion }
            
            if showRangeSelector { rangeSelector }
        }
    }
    
    @available(iOS 17.0, *)
    var lineChart: some View {
        
        VStack {
            
            let cumulativeProfitArray = viewModel.calculateCumulativeProfit(sessions: yearSelection != nil ? yearSelection! : dateRange,
                                                                            sessionFilter: chartSessionFilter)
            let lineGradient = LinearGradient(colors: [chartSessionFilter != .tournaments ? .chartAccent : .donutChartOrange,
                                                   chartSessionFilter != .tournaments ? .chartBase : .orange],
                                          startPoint: .topTrailing, endPoint: .bottomLeading)
            let areaGradient = LinearGradient(colors: [chartSessionFilter != .tournaments ? Color("lightBlue").opacity(0.85) : .donutChartOrange, .clear], startPoint: .top, endPoint: .bottom)
            
            Chart {
                
                ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .opacity(showChart ? 1.0 : 0.0)
                        .foregroundStyle(lineGradient)
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(areaGradient)
                        .opacity(showChart ? 0.15 : 0.0)
                    
                    
                    if let selectedIndex {
                        
                        PointMark(x: .value("Point", selectedIndex), y: .value("Profit", profitAnnotation ?? 0))
                            .foregroundStyle(Color.brandWhite)
                    }
                }
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                if let selectedIndex {
                    
                    RuleMark(x: .value("Selected Date", selectedIndex))
                        .lineStyle(StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundStyle(.gray.opacity(0.2))
                }
            }
            .onAppear {
                withAnimation {
                    showChart = true
                }
            }
            .overlay(
                PatternView()
                    .opacity(showChart ? 0.33 : 0.0)
                    .allowsHitTesting(false)
                    .mask(
                        Chart {
                            ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                                AreaMark(x: .value("Time", index), y: .value("Profit", total))
                            }
                            .interpolationMethod(.catmullRom)
                        }
                    )
            )
            .animation(.easeIn(duration: 1.2), value: showChart)
            .sensoryFeedback(.selection, trigger: selectedIndex)
            .chartXSelection(value: $selectedIndex)
            .chartXAxis(.hidden)
            .chartYScale(domain: [convertedData.min()!, convertedData.max()!])
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if showYAxis {
                            if let intValue = value.as(Int.self) {
                                Text(intValue.axisShortHand(viewModel.userCurrency))
                                    .captionStyle()
                                    .padding(.leading, 12)
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
            
            let cumulativeProfitArray = viewModel.calculateCumulativeProfit(sessions: yearSelection != nil ? yearSelection! : dateRange, sessionFilter: chartSessionFilter)
            
            Chart {
                
                ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .opacity(showChart ? 1.0 : 0.0)
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [chartSessionFilter != .tournaments ? Color("lightBlue").opacity(0.85) : .donutChartGreen, .clear], startPoint: .top, endPoint: .bottom))
                        .opacity(showChart ? 0.15 : 0.0)
                }
                .foregroundStyle(LinearGradient(colors: [chartSessionFilter != .tournaments ? .chartAccent : .donutChartGreen,
                                                         chartSessionFilter != .tournaments ? .chartBase : .donutChartDarkBlue],
                                                startPoint: .topTrailing, endPoint: .bottomLeading))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
            .onAppear {
                withAnimation {
                    showChart = true
                }
            }
            .overlay(
                PatternView()
                    .opacity(showChart ? 0.33 : 0.0)
                    .allowsHitTesting(false)
                    .mask(
                        Chart {
                            ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                                AreaMark(x: .value("Time", index), y: .value("Profit", total))
                            }
                            .interpolationMethod(.catmullRom)
                        }
                    )
            )
            .animation(.easeIn(duration: 1.2), value: showChart)
            .chartXAxis(.hidden)
            .chartYScale(domain: [convertedData.min()!, convertedData.max()!])
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if showYAxis {
                            if let intValue = value.as(Int.self) {
                                Text(intValue.axisShortHand(viewModel.userCurrency))
                                    .captionStyle()
                                    .padding(.leading, 12)
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
            Picker("", selection: $chartSessionFilter) {
                ForEach(SessionFilter.allCases, id: \.self) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
        } label: {
            Text(chartSessionFilter.rawValue.capitalized + " ›")
                .bodyStyle()
        }
        .tint(.brandPrimary)
        .transaction { transaction in
            transaction.animation = nil
        }
        
    }
    
    var rangeSelector: some View {
        
        HStack (spacing: 13) {
            
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
    
    private func calculatePercentChange(from oldValue: Int, to newValue: Int) -> String {
        
        guard oldValue != 0 else {
            return "N/A"
        }
        
        let change = (Double(newValue) - Double(oldValue)) / Double(oldValue) * 100
        return String(format: "%.2f%%", change)
    }
    
    struct PatternView: View {
        
        var body: some View {
            
            GeometryReader { geometry in
                let patternSize: CGFloat = 3 // Size of individual dots
                let spacing: CGFloat = 10 // Spacing between dots
                let dotColor: Color = Color("lightBlue").opacity(0.1)

                Canvas { context, size in
                    for y in stride(from: 0, to: size.height, by: patternSize + spacing) {
                        for x in stride(from: 0, to: size.width, by: patternSize + spacing) {
                            context.fill(
                                Path(ellipseIn: CGRect(x: x, y: y, width: patternSize, height: patternSize)),
                                with: .color(dotColor)
                            )
                        }
                    }
                }
            }
        }
    }
}

struct SwiftChartsPractice_Previews: PreviewProvider {
    
    static var previews: some View {
        BankrollLineChart(showTitle: true, showYAxis: true, showRangeSelector: true, overlayAnnotation: true)
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
            .frame(height: 400)
            .padding()
    }
}
