//
//  AdvancedTournamentReport.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/4/24.
//

import SwiftUI
import Charts

struct AdvancedTournamentReport: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: SessionsListViewModel
    @State private var yearFilter: String = Date().getYear()
    @State private var chartYearSelection: [PokerSession_v2]?
    
    var chartYearFilter: [PokerSession_v2] {
        return vm.allTournamentSessions().filter({ $0.date.getYear() == yearFilter })
    }
    var convertedData: [Int] {
        // Start with zero as our initial data point so chart doesn't look goofy
        var originalDataPoint = [0]
        let newDataPoints = vm.calculateCumulativeProfit(sessions: chartYearFilter, sessionFilter: .tournaments)
        originalDataPoint += newDataPoints
        return originalDataPoint
    }
    
    var body: some View {
        
        ScrollView {
                
            VStack {
                
                monthlyTotals
                
                yearTotals
            
                tournamentChart
                
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .background(Color.brandBackground)
        .dynamicTypeSize(.xSmall...DynamicTypeSize.large)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Tournament Report"))
        .toolbar {
            ToolbarItem {
                headerInfo
            }
            
            ToolbarItem(placement: .principal) {
                Text("Tournament Report")
                    .font(.custom("Asap-Bold", size: 18))
            }
        }
    }
    
    var headerInfo: some View {
        
        VStack {
            
            Menu {
                let allYears = vm.allSessions.map({ $0.date.getYear() }).uniqued()
                Menu {
                    Picker("", selection: $yearFilter) {
                        ForEach(allYears, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    
                } label: {
                    Text("Filter by Year")
                }
                
                Divider()
                
                Button {
                    yearFilter = Date().getYear()
                    
                } label: {
                    Text("Clear Filters")
                    Image(systemName: "x.circle")
                }
                
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
            .accentColor(Color.brandPrimary)
            .transaction { transaction in
                transaction.animation = nil
            }
        }
    }
    
    var monthlyTotals: some View {
        
        VStack (spacing: 10) {
            
            HStack {
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Color(.systemGray))
                    .fontWeight(.bold)
                    .frame(width: 60, alignment: .trailing)
                
                Image(systemName: "cart.fill")
                    .foregroundStyle(Color(.systemGray))
                    .fontWeight(.bold)
                    .frame(width: 60, alignment: .trailing)
                
                Image(systemName: "dollarsign")
                    .foregroundStyle(Color(.systemGray))
                    .fontWeight(.bold)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.bottom, 10)
            
            Divider().padding(.bottom, 10)
            
            ForEach(vm.months, id: \.self) { month in
                HStack {
                    Text(month)
                    
                    Spacer()
                    
                    let filteredMonths = vm.allSessions.filter({ $0.date.getYear() == yearFilter && $0.isTournament == true })
                    let totalBuyIns = filteredMonths.filter({ $0.date.getMonth() == month }).reduce(0) { total, session in
                        total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
                    }
                    let grossProfit = filteredMonths.filter({ $0.date.getMonth() == month }).map { $0.profit }.reduce(0, +) + totalBuyIns
                    let netProfit = grossProfit - totalBuyIns
                    
                    Text(grossProfit == 0 ? "-" : grossProfit.currencyShortHand(vm.userCurrency))
                        .profitColor(total: grossProfit)
                        .frame(width: 62, alignment: .trailing)
                    
                    // Necessary because the stystem doesn't know this value is technically a "negative"
                    Text(totalBuyIns != 0 ? "-\(totalBuyIns.currencyShortHand(vm.userCurrency))" : "-")
                        .foregroundStyle(totalBuyIns != 0 ? .red : .secondary)
                        .frame(width: 62, alignment: .trailing)
                    
                    Text(netProfit == 0 ? "-" : netProfit.currencyShortHand(vm.userCurrency))
                        .foregroundStyle(netProfit > 0 ? Color.lightGreen : netProfit < 0 ? .red : .secondary)
                        .frame(width: 62, alignment: .trailing)
                    
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
            }
        }
        .padding(20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top)
    }
    
    var yearTotals: some View {
        
        VStack (spacing: 10) {
            
            let tournamentListByYear = vm.allSessions.filter({ $0.isTournament == true && $0.date.getYear() == yearFilter })
            let totalBuyInsByYear = tournamentListByYear.reduce(0) { total, session in
                total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
            }
            let bankrollTotalByYear = vm.bankrollByYear(year: yearFilter, sessionFilter: .tournaments) + totalBuyInsByYear
            let netProfit = bankrollTotalByYear - totalBuyInsByYear
            let tournamentCount = tournamentListByYear.count
            let roi = yearlyTournamentROI(tournaments: tournamentListByYear)
            let hoursPlayed = tournamentListByYear.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
            let bullets = (tournamentListByYear.map { $0.rebuyCount ?? 0 }.reduce(0, +)) + tournamentCount
            
            HStack {
                Image(systemName: "trophy.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Winnings")
                
                Spacer()
                
                Text(bankrollTotalByYear, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bankrollTotalByYear)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "cart.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Buy Ins")
                
                Spacer()
                
                Text(totalBuyInsByYear, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundStyle(totalBuyInsByYear != 0 ? .red : .secondary)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "dollarsign")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Net Profit")
                
                Spacer()
                
                Text(netProfit, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: netProfit)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "percent")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Total ROI")
                
                Spacer()
                
                Text(roi)
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "clock")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Hours Played")
                
                Spacer()
                
                Text("\(hoursPlayed)h")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image(systemName: "person.2.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Tournaments")
                
                Spacer()
                
                Text("\(tournamentCount)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
            
            HStack {
                Image("bullet-pointed-icon")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Bullets Fired")
                
                Spacer()
                
                Text("\(bullets)")
                    .font(.custom("Asap-Black", size: 20, relativeTo: .callout))
            }
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top, 15)
    }
    
    var tournamentChart: some View {
        
        VStack {
            
            HStack {
                Text("Tournament Winnings")
                    .cardTitleStyle()
                
                Spacer()
            }
            .padding(.bottom, 40)
            
            Chart {
                ForEach(Array(convertedData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [.donutChartOrange, .orange], startPoint: .topTrailing, endPoint: .bottomLeading))
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [.donutChartOrange, .clear], startPoint: .top, endPoint: .bottom))
                        .opacity(0.18)
                        
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(.gray.opacity(0.33))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.axisShortHand(vm.userCurrency))
                                .captionStyle()
                                .padding(.leading, 25)
                        }
                    }
                }
            }
            .overlay {
                if convertedData.count < 2 {
                    VStack {
                        Text("No chart data to display.")
                            .calloutStyle()
                            .foregroundStyle(.secondary)
                    }
                    .offset(y: -20)
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
        .padding(.horizontal, 20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top, 15)
        .padding(.bottom, 60)
    }
    
    private func yearlyTournamentROI(tournaments: [PokerSession_v2]) -> String {
        guard !tournaments.isEmpty else { return "0%" }
        
        let totalBuyIns = tournaments.reduce(0) { total, session in
            total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
        }
        let totalWinnings = tournaments.map({ $0.profit }).reduce(0,+) + totalBuyIns
        
        guard totalBuyIns > 0 else { return "0%" }
        
        let returnOnInvestment = (Double(totalWinnings) - Double(totalBuyIns)) / Double(totalBuyIns)
        return returnOnInvestment.asPercent()
    }
}

#Preview {
    NavigationView {
        AdvancedTournamentReport(vm: SessionsListViewModel())
            .preferredColorScheme(.dark)
        
    }
}
