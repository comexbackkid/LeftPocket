
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
    @Binding var minimizeLineChart: Bool
    @AppStorage("sessionFilter") private var chartSessionFilter: SessionFilter = .all
    @AppStorage("dateRangeSelection") private var chartRange: RangeSelection = .all
    @AppStorage("chartBankrollFilter") private var bankrollFilter: BankrollSelection = .default
    
    // Optional year selector, only used in Annual Report View. Overrides dateRange if used
    var customDateRange: [PokerSession_v2]?
    private var data: [Int] { viewModel.bankrollLineChartData }
    private var annotationProfit: Int? {
        guard let i = selectedIndex, data.indices.contains(i) else { return nil }
        return data[i]
    }
    
    let showTitle: Bool
    let showYAxis: Bool
    let showRangeSelector: Bool
    let overlayAnnotation: Bool
    let showToggleAndFilter: Bool

    var body: some View {
        
        VStack {
            
            if showTitle { header }

            lineChart

            if showRangeSelector { rangeSelector }
        }
        .onAppear {
            viewModel.refreshFiltered(bankroll: bankrollFilter, range: chartRange, session: chartSessionFilter)
        }
    }
    
    var lineChart: some View {
        
        VStack {
            let lineGradient = LinearGradient(gradient: Gradient(colors: chartSessionFilter.lineChartColors),
                                              startPoint: .topTrailing,
                                              endPoint: .bottomLeading)
            
            let areaGradient = LinearGradient(gradient: Gradient(colors: chartSessionFilter.lineChartAreaColors),
                                              startPoint: .top,
                                              endPoint: .bottom)
            
            Chart {
                ForEach(Array(viewModel.bankrollLineChartData.enumerated()), id: \.offset) { index, total in
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(lineGradient)
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(areaGradient)
                        .opacity(0.35)
                    
                    if let profit = annotationProfit, selectedIndex == index {
                        
                        PointMark(x: .value("Time", index), y: .value("Profit", profit))
                            .symbolSize(100)
                            .foregroundStyle(colorScheme == .dark ? Color.brandWhite : .black)
                            
                        PointMark(x: .value("Time", index), y: .value("Profit", profit))
                            .symbolSize(40)
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                    }
                }
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                if let idx = selectedIndex {
                    RuleMark(x: .value("Selected Date", idx))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6]))
                        .foregroundStyle(.gray.opacity(0.33))
                }
            }
            .sensoryFeedback(.selection, trigger: selectedIndex)
            .chartXSelection(value: $selectedIndex)
            .chartXAxis(.hidden)
            .chartYScale(domain: [data.min()!, data.max()!])
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: minimizeLineChart ? 3 : 4)) { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if showYAxis {
                            if let intValue = value.as(Int.self) {
                                Text(intValue.axisShortHand(viewModel.userCurrency))
                                    .font(.custom("AsapCondensed-Light", size: 12, relativeTo: .caption2))
                                    .padding(.leading, 12)
                            }
                        }
                    }
                }
            }
            .overlay {
                if data.count == 1 {
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
        .onChange(of: chartRange) { newRange in
            viewModel.refreshFiltered(bankroll: bankrollFilter, range: newRange, session: chartSessionFilter)
        }
        .onChange(of: bankrollFilter) { newBankroll in
            viewModel.refreshFiltered(bankroll: newBankroll, range: chartRange, session: chartSessionFilter)
        }
        .onChange(of: chartSessionFilter) { newSessionFilter in
            viewModel.refreshFiltered(bankroll: bankrollFilter, range: chartRange, session: newSessionFilter)
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
                    Text("Default").tag(BankrollSelection.`default`)
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
                    
                    viewModel.refreshFiltered(
                        bankroll: bankrollFilter,
                        range:   chartRange,
                        session: chartSessionFilter
                    )
                    
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

    var header: some View {
        
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Player Profit").cardTitleStyle()
                
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    let defaultProfit = data.last ?? 0
                    
                    if let profit = annotationProfit {
                        if selectedIndex != 0 {
                            Image(systemName: "arrow.up.right")
                                .chartIntProfitColor(amountText: profit, defaultProfit: defaultProfit)
                                .rotationEffect(.degrees(profit < 0 ? 90 : 0))
                                .animation(.default.speed(2), value: profit)
                        }
                        Text(
                            "\(abs(profit).formatted(.currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))))"
                        )
                        .font(.custom("Asap-Medium", size: 17))
                        .chartIntProfitColor(amountText: profit, defaultProfit: defaultProfit)
                        
                    } else {
                        // fallback: show last data point
                        Text(
                            "\(abs(defaultProfit).formatted(.currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))))"
                        )
                        .font(.custom("Asap-Medium", size: 17))
                        .chartIntProfitColor(amountText: defaultProfit,
                                             defaultProfit: defaultProfit)
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
        .fullScreenCover(isPresented: $viewModel.lineChartFullScreen) {
            LineChartFullScreen(lineChartFullScreen: $viewModel.lineChartFullScreen)
                .interfaceOrientations(.allButUpsideDown)
        }
    }
}

struct SwiftChartsPractice_Previews: PreviewProvider {
    
    static var previews: some View {
        BankrollLineChart(minimizeLineChart: .constant(false), showTitle: true, showYAxis: true, showRangeSelector: true, overlayAnnotation: true, showToggleAndFilter: true)
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
            .frame(height: 400)
            .padding()
    }
}
