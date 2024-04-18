
//  SwiftChartsPractice.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/22.
//

import SwiftUI
import Charts

struct SwiftLineChartsPractice: View {
    
    enum ChartRange {
        case all, oneMonth, sixMonth, oneYear
    }
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State private var selectedIndex: Int?
    @State private var animationProgress: CGFloat = 0.0
    @State private var showChart: Bool = false
    @State var sessionFilter: SessionFilter = .all
    @State private var chartRange: ChartRange = .all
    
    var dateRange: [PokerSession] {
        switch chartRange {
        case .all: return viewModel.sessions
            
        case .oneMonth: return filterSessionsForLastThreeMonths()
            
        case .sixMonth: return filterSessionsForLastSixMonths()
            
        case .oneYear: return filterSessionsForLastTwelveMonths()
            
        }
    }
    
    // Optional year selector, only used in Annual Report View. Overrides dateRange if used
    var yearSelection: [PokerSession]?
    var profitAnnotation: Int? {
        
        getProfitForIndex(index: selectedIndex ?? 0, cumulativeProfits: convertedData)
    }
    var convertedData: [Int] {
        
        // Start with zero as our initial data point so chart doesn't look goofy
        var originalDataPoint = [0]
        let newDataPoints = calculateCumulativeProfit(sessions: yearSelection != nil ? yearSelection! : dateRange, sessionFilter: sessionFilter)
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
                    
                    Button {
                        viewModel.lineChartFullScreen.toggle()
                    } label: {
                        Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                    }
                    .tint(.brandPrimary)
                    .padding(.horizontal, 5)
                    
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
                .padding(.bottom, 40)
            }
            
            if #available(iOS 17.0, *) {
                lineChart
            } else {
                lineChartOldVersion
            }
            
            if showRangeSelector {
                rangeSelector
            }
        }
    }
    
    @available(iOS 17.0, *)
    var lineChart: some View {
        
        Chart {
            
            ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                
                LineMark(x: .value("Time", index), y: .value("Profit", total))
                    .opacity(showChart ? 1.0 : 0.0)
                
                AreaMark(x: .value("Time", index), y: .value("Profit", total))
                    .foregroundStyle(LinearGradient(colors: [Color("lightBlue"), .clear], startPoint: .top, endPoint: .bottom))
                    .opacity(showChart ? 0.15 : 0.0)
                
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
    
    var lineChartOldVersion: some View {
        Chart {
            
            ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                
                LineMark(x: .value("Time", index), y: .value("Profit", total))
                    .opacity(showChart ? 1.0 : 0.0)
                
                AreaMark(x: .value("Time", index), y: .value("Profit", total))
                    .foregroundStyle(LinearGradient(colors: [Color("lightBlue"), .clear], startPoint: .top, endPoint: .bottom))
                    .opacity(showChart ? 0.2 : 0.0)
                

            }
            .foregroundStyle(LinearGradient(colors: [.chartAccent, .chartBase], startPoint: .topTrailing, endPoint: .bottomLeading))
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
    }
    
    var rangeSelector: some View {
        
        HStack (spacing: 25) {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                chartRange = .all
            } label: {
                Text("All")
                    .bodyStyle()
            }
            .tint(chartRange == .all ? .primary : .brandPrimary)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                chartRange = .oneYear
            } label: {
                Text("1Y")
                    .bodyStyle()
            }
            .tint(chartRange == .oneYear ? .primary : .brandPrimary)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                chartRange = .sixMonth
            } label: {
                Text("6M")
                    .bodyStyle()
            }
            .tint(chartRange == .sixMonth ? .primary : .brandPrimary)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                chartRange = .oneMonth
            } label: {
                Text("1M")
                    .bodyStyle()
            }
            .tint(chartRange == .oneMonth ? .primary : .brandPrimary)
            
            Spacer()
        }
        .padding(.top, 20)
        
    }
    
    func calculateCumulativeProfit(sessions: [PokerSession], sessionFilter: SessionFilter) -> [Int] {
        
        // We run this so tha twe can just use the Index as our X Axis value. Keeps spacing uniform and neat looking.
        // Then, in chart configuration we just plot along the Index value, and Int is our cumulative profit amount.
        var cumulativeProfit = 0
        
        // Take the cash / tournament filter and assign to this variable
        var filteredSessions: [PokerSession] {
            switch sessionFilter {
            case .all:
                return sessions
            case .cash:
                return sessions.filter({ $0.isTournament == false || $0.isTournament == nil })
            case .tournaments:
                return sessions.filter({ $0.isTournament == true })
            }
        }

        // I'm having to manually sort the sessions array here, even though it's doing it in the Add Session function. Don't know why.
        let result = filteredSessions.sorted(by: { $0.date < $1.date }).map { session -> Int in
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
    
    func filterSessionsForLastThreeMonths() -> [PokerSession] {
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date())

        return viewModel.sessions.filter { session in
            guard let threeMonthsAgo = threeMonthsAgo else { return false }
            return session.date >= threeMonthsAgo
        }
    }
    
    func filterSessionsForLastSixMonths() -> [PokerSession] {
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -6, to: Date())

        return viewModel.sessions.filter { session in
            guard let threeMonthsAgo = threeMonthsAgo else { return false }
            return session.date >= threeMonthsAgo
        }
    }
    
    func filterSessionsForLastTwelveMonths() -> [PokerSession] {
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -12, to: Date())

        return viewModel.sessions.filter { session in
            guard let threeMonthsAgo = threeMonthsAgo else { return false }
            return session.date >= threeMonthsAgo
        }
    }
}

struct SwiftChartsPractice_Previews: PreviewProvider {
    
    static var previews: some View {
        SwiftLineChartsPractice(showTitle: true, showYAxis: true, showRangeSelector: true, overlayAnnotation: true)
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
            .frame(height: 350)
            .padding()
    }
}
