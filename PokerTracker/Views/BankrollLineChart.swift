
//  SwiftChartsPractice.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/22.
//

import SwiftUI
import Charts

struct BankrollLineChart: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0.0
    @State private var showChart: Bool = false
    @Binding var minimizeLineChart: Bool
    @AppStorage("sessionFilter") private var chartSessionFilter: SessionFilter = .all
    @AppStorage("dateRangeSelection") private var chartRange: RangeSelection = .all
    @State private var bankrollFilter: BankrollSelection = .default
    
    // Optional year selector, only used in Annual Report View. Overrides dateRange if used
    var customDateRange: [PokerSession_v2]?
    var dateRange: [PokerSession_v2] {
        let allSessions: [PokerSession_v2] = {
            switch bankrollFilter {
            case .all: return viewModel.sessions + viewModel.bankrolls.flatMap(\.sessions)
            case .default: return viewModel.sessions
            case .custom(let id): return viewModel.bankrolls.first(where: { $0.id == id })?.sessions ?? []
            }
        }()
        
        let sessionsByDate: [PokerSession_v2] = {
            switch chartRange {
            case .all: return allSessions
            case .oneMonth: return allSessions.filter { $0.date >= Calendar.current.date(byAdding: .month, value: -1, to: Date())! }
            case .threeMonth: return allSessions.filter { $0.date >= Calendar.current.date(byAdding: .month, value: -3, to: Date())! }
            case .sixMonth: return allSessions.filter { $0.date >= Calendar.current.date(byAdding: .month, value: -6, to: Date())! }
            case .oneYear: return allSessions.filter { $0.date >= Calendar.current.date(byAdding: .year, value: -1, to: Date())! }
            case .ytd:
                let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
                return allSessions.filter { $0.date >= startOfYear }
            }
        }()
        
        switch chartSessionFilter {
        case .all:
            return sessionsByDate
        case .cash:
            return sessionsByDate.filter { !$0.isTournament }
        case .tournaments:
            return sessionsByDate.filter { $0.isTournament }
        }
    }
    var profitAnnotation: Int? {
        getProfitForIndex(index: selectedIndex ?? 0, cumulativeProfits: convertedData)
    }
    var convertedData: [Int] {
        var originalDataPoint = [0]
        let newDataPoints = viewModel.calculateCumulativeProfit(sessions: customDateRange ?? dateRange, sessionFilter: chartSessionFilter)
        originalDataPoint += newDataPoints
        return originalDataPoint
    }
    
    let showTitle: Bool
    let showYAxis: Bool
    let showRangeSelector: Bool
    let showPatternBackground: Bool
    let overlayAnnotation: Bool
    let showToggleAndFilter: Bool

    var body: some View {
        
        VStack {
            
            if showTitle {
                
                HStack (alignment: .top) {
                    
                    VStack (alignment: .leading, spacing: 3) {
                        Text("Player Profit")
                            .cardTitleStyle()
                        
                        let amountText: Int? = profitAnnotation
                        var defaultProfit: Int {
                            if selectedIndex == 0 {
                                return convertedData.first!
                                
                            } else {
                                return convertedData.last!
                            }
                        }
                        
                        Group {
                            if let amountText {
                                HStack (alignment: .firstTextBaseline, spacing: 5) {
                                    
                                    if selectedIndex != 0 && !dateRange.isEmpty {
                                        Image(systemName: "arrow.up.right")
                                            .chartIntProfitColor(amountText: amountText, defaultProfit: defaultProfit)
                                            .rotationEffect(.degrees(amountText > 0 ? 0 : amountText < 0 ? 90 : defaultProfit > 0 ? 0 : 90))
                                            .animation(.default.speed(2), value: amountText)
                                    }
                                    
                                    Text(amountText == 0 ? "\(abs(defaultProfit).formatted(.currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))))" : "\(abs(amountText).formatted(.currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))))")
                                        .font(.custom("Asap-Medium", size: 17))
                                        .chartIntProfitColor(amountText: amountText, defaultProfit: defaultProfit)
                                    
                                }
                            }
                        }
                        .animation(nil, value: selectedIndex)
                    }
                    
                    Spacer()
                    
                    if showToggleAndFilter {
                        
                        fullScreenToggleButton
                        
                        filterButton
                    }
                }
                .padding(.bottom, 6)
                .fullScreenCover(isPresented: $viewModel.lineChartFullScreen, content: {
                    LineChartFullScreen(lineChartFullScreen: $viewModel.lineChartFullScreen)
                        .interfaceOrientations(.allButUpsideDown)
                })
            }
      
            lineChart

            if showRangeSelector { rangeSelector }
        }
    }
    
    var lineChart: some View {
        
        VStack {
            
            let cumulativeProfitArray = viewModel.calculateCumulativeProfit(sessions: customDateRange != nil ? customDateRange! : dateRange,
                                                                            sessionFilter: chartSessionFilter)
            let lineGradient = LinearGradient(colors: [chartSessionFilter != .tournaments ? .chartAccent : .donutChartOrange,
                                                   chartSessionFilter != .tournaments ? .chartBase : .orange],
                                          startPoint: .topTrailing, endPoint: .bottomLeading)
            let areaGradient = LinearGradient(colors: [chartSessionFilter != .tournaments ? Color("lightBlue").opacity(0.85) : .donutChartOrange, chartSessionFilter != .tournaments ? Color("lightBlue").opacity(0.25) : .donutChartOrange.opacity(0.25), .clear, .clear], startPoint: .top, endPoint: .bottom)
            
            Chart {
                ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .opacity(showChart ? 1.0 : 0.0)
                        .foregroundStyle(lineGradient)
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(areaGradient)
                        .opacity(showChart ? 0.25 : 0.0)
                    
                    
                    if let selectedIndex {
                        PointMark(x: .value("Point", selectedIndex), y: .value("Profit", profitAnnotation ?? 0))
                            .foregroundStyle(colorScheme == .dark ? Color.brandWhite : Color.black)
                            .symbolSize(100)
                        
                        PointMark(x: .value("Point", selectedIndex), y: .value("Profit", profitAnnotation ?? 0))
                            .foregroundStyle(colorScheme == .dark ? Color.black : .white)
                            .symbolSize(40)
                    }
                }
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                if let selectedIndex {
                    RuleMark(x: .value("Selected Date", selectedIndex))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6]))
                        .foregroundStyle(.gray.opacity(0.33))
                }
            }
            .onAppear {
                withAnimation {
                    showChart = true
                }
            }
            .overlay(
                PatternView()
                    .opacity(showChart && showPatternBackground ? 0.33 : 0.0)
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
                AxisMarks(position: .trailing, values: .automatic(desiredCount: minimizeLineChart ? 3 : 4)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if showYAxis {
                            if let intValue = value.as(Int.self) {
                                Text(intValue.axisShortHand(viewModel.userCurrency))
                                    .font(.custom("AsapCondensed-Bold", size: 12, relativeTo: .caption2))
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
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
            }
            .allowsHitTesting(cumulativeProfitArray.isEmpty ? false : true)
        }
    }
    
    var fullScreenToggleButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .soft)
            impact.impactOccurred()
            viewModel.lineChartFullScreen.toggle()
            
        } label: {
            Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
        }
        .tint(.brandPrimary)
        .padding(.horizontal, 5)
        
    }
    
    var filterButton: some View {
        
        Menu {
            
            Menu {
                Picker("Bankroll Picker", selection: $bankrollFilter) {
                    Text("All").tag(BankrollSelection.all)
                    Text("Default").tag(BankrollSelection.default)
                    ForEach(viewModel.bankrolls) { bankroll in
                        Text(bankroll.name).tag(BankrollSelection.custom(bankroll.id))
                    }
                }
            } label: {
                HStack {
                    Text("Bankrolls")
                    Image(systemName: "bag.fill")
                }
            }
            
            Picker("Session Filter", selection: $chartSessionFilter) {
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
        
        HStack (spacing: 10) {
            
            ForEach(RangeSelection.allCases, id: \.self) { range in
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
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
            
            if viewModel.lineChartFullScreen == false {
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        minimizeLineChart.toggle()
                    }
                    
                } label: {
                    Image(systemName: "rectangle.expand.vertical")
                }
                .tint(.brandPrimary)
            }
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
        BankrollLineChart(minimizeLineChart: .constant(false), showTitle: true, showYAxis: true, showRangeSelector: true, showPatternBackground: false, overlayAnnotation: true, showToggleAndFilter: true)
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
            .frame(height: 400)
            .padding()
    }
}
