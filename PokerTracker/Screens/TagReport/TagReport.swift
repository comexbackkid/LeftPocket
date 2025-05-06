//
//  TagReport.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/26/24.
//

import SwiftUI

struct TagReport: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var tagsFilter: String = ""
    @State private var expensesPopover = false
    @State private var grossIncomePopover = false
    
    var imageGenerator: Image {
        
        let sessions = viewModel.allSessions.filter({ $0.tags.first == tagsFilter })
        let firstLocation = sessions.last?.location
        
        if let localImage = firstLocation?.localImage {
            return Image(localImage)
            
        } else if let importedImagePath = firstLocation?.importedImage {
            if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                return Image(uiImage: uiImage)
                
            } else {
                return Image("defaultlocation-header")
            }
            
        } else {
            return Image("defaultlocation-header")
        }
    }
    var taggedSessions: [PokerSession_v2] { return viewModel.allSessions.filter({ $0.tags.first == tagsFilter }) }
    
    var body: some View {
        
        ScrollView {
            
            HStack { Spacer() }
            
            VStack (spacing: 0) {
                
                headerImage
                
                VStack {
                    
                    tagSelection
                    
                    Divider().padding(.vertical)
                    
                    toplineIncome
                    
                    Divider().padding(.vertical)
                    
                    detailedIncome
                }
                .padding(30)
            }
            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
            .lineSpacing(2.5)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .padding(.bottom, 14)
            
            lineChart
        }
        .background(Color.brandBackground)
        .accentColor(.brandPrimary)
    }
    
    var title: some View {
        
        HStack {
            Text("Tags Report")
                .titleStyle()
                .padding(.top, -37)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var headerImage: some View {
        
        imageGenerator
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 150)
            .clipped()
            .overlay {
                LinearGradient(colors: [.black, .clear, .clear], startPoint: .topTrailing, endPoint: .bottomLeading)
                    .opacity(0.7)
            }
            .overlay {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "tag.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Spacer()
                    }
                }
                .padding()
            }
    }
    
    var tagSelection: some View {
        
        HStack {
            
            let taggedSessions = viewModel.allSessions.compactMap { $0.tags.first }.filter { !$0.isEmpty }.uniqued()
            
            Text("Tag Name")
                .bodyStyle()
            
            Spacer()
            
            Menu {
                Picker("Tag Selection", selection: $tagsFilter) {
                    ForEach(taggedSessions, id: \.self) {
                        Text($0).tag($0)
                    }
                    
                    if taggedSessions.isEmpty {
                        Text("No tags found")
                            .disabled(true)
                            .allowsHitTesting(false)
                    }
                }
            } label: {
                
                if tagsFilter.isEmpty {
                    Text("Please select ›")
                        .bodyStyle()
                } else {
                    Text(tagsFilter)
                        .bodyStyle()
                        .lineLimit(1)
                }
            }
            .accentColor(Color.brandPrimary)
            .transaction { transaction in
                transaction.animation = nil
            }
        }
    }
    
    var toplineIncome: some View {
        
        VStack (spacing: 12) {
            
            let highHands = tagHighHands(tag: tagsFilter)
            let grossIncome = tagGrossIncome(tag: tagsFilter) + highHands
            let expenses = tagExpenses(tag: tagsFilter)
            let netProfit = grossIncome - expenses
            
            HStack {
                HStack {
                    Text("Gross Income")
                    
                    Button {
                        grossIncomePopover = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
                .popover(isPresented: $grossIncomePopover, arrowEdge: .bottom, content: {
                    PopoverView(bodyText: "Gross Income includes total income from Sessions in this Tag Report, including high hand bonuses.")
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .frame(height: 145)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                        .shadow(radius: 10)
                })
                
                Spacer()
                Text(grossIncome, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: grossIncome)
            }

            HStack {
                HStack {
                    Text("Expenses")
                    
                    Button {
                        expensesPopover = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
                
                Spacer()
                Text(expenses, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(expenses > 0 ? .red : Color(.systemGray))
            }
            .popover(isPresented: $expensesPopover, arrowEdge: .bottom, content: {
                PopoverView(bodyText: "Expenses include both on & off-the-table expenses, i.e. expenses from Transactions. Expenses also include your Tournament buy ins & rebuys.")
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    .frame(height: 145)
                    .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                    .presentationCompactAdaptation(.popover)
                    .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                    .shadow(radius: 10)
            })
            
            HStack {
                Text("Net Profit")
                
                Spacer()
                
                Text(netProfit, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: netProfit)
            }
        }
    }
    
    var detailedIncome: some View {
        
        VStack (spacing: 12) {
            
            let sessionCount = tagSessionCount(tag: tagsFilter)
            let hoursPlayed = tagTotalHours(tag: tagsFilter)
            let highHands = tagHighHands(tag: tagsFilter)
            let bestSession = tagBestSession(tag: tagsFilter)
            let profitPerSession = tagProfitPerSession(tag: tagsFilter)
            let hourlyRate = tagHourlyRate(tag: tagsFilter)
            let roi = tagTournamentROI(tag: tagsFilter)
            let actionSold = tagActionSold(tag: tagsFilter)
            let startDate = tagDateRange(tag: tagsFilter)?.0.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits).year(.twoDigits))
            let endDate = tagDateRange(tag: tagsFilter)?.1.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits).year(.twoDigits))
            
            HStack {
                Text("Hourly Rate")
                
                Spacer()
                
                Text(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: hourlyRate)
            }
            
            HStack {
                Text("Profit Per Session")
                
                Spacer()
                
                Text(profitPerSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: profitPerSession)
            }
            
            HStack {
                Text("Biggest Session")
                
                Spacer()
                
                Text(bestSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bestSession)
            }
            
            HStack {
                Text("High Hand Bonuses")
                
                Spacer()
                
                Text(highHands, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: highHands)
            }
            
            HStack {
                Text("No. of Sessions")
                
                Spacer()
                
                Text("\(sessionCount)")
            }
            
            HStack {
                Text("Tournament ROI")
                
                Spacer()
                
                Text(roi)
            }
            
            HStack {
                Text("Action Sold")
                
                Spacer()
                
                Text(actionSold, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
            }
            
            HStack {
                Text("Hours Played")
                
                Spacer()
                
                Text(hoursPlayed)
                    
            }
            
            HStack {
                Text("Dates")
                
                Spacer()
                
                if let startDate, let endDate {
                    Text("\(startDate) - \(endDate)")
                } else {
                    Text("None")
                }
            }
        }
    }
    
    var lineChart: some View {
        BankrollLineChartSimple(sessions: taggedSessions, showTitle: true)
            .padding(20)
            .padding(.bottom)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 360)
            .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .padding(.bottom, 80)
    }
    
    private func tagSessionCount(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        return matchedSessions.count
    }
    
    private func tagTotalHours(tag: String) -> String {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return "0" }
        
        let hoursArray: [Int] = matchedSessions.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = matchedSessions.map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +)
        let totalMinutes = minutesArray.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        
        return dateComponents.durationShortHand()
    }
    
    private func tagWinRatio(tag: String) -> String {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return "0%" }
        
        let wins = Double(matchedSessions.filter({ $0.profit > 0 }).count)
        let sessions = Double(matchedSessions.count)
        let winRatio = wins / sessions
        return winRatio.asPercent()
    }
    
    private func tagHighHands(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let highHandsTotal = matchedSessions.map({ $0.highHandBonus }).reduce(0, +)
        return highHandsTotal
    }
    
    private func tagBestSession(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        guard let bestSession = matchedSessions.map({ $0.profit }).max(by: { $0 < $1 }) else {
            return 0
        }
        
        return bestSession
    }
    
    private func tagProfitPerSession(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let profit = matchedSessions.map({ $0.profit }).reduce(0, +)
        let count = matchedSessions.count
        return profit / count
    }
    
    private func tagHourlyRate(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let totalHours = Float(matchedSessions.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+))
        let totalMinutes = Float(matchedSessions.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
        let totalTime = totalHours + (totalMinutes / 60)
        let totalEarnings = Float(matchedSessions.map({ $0.profit }).reduce(0, +))
        
        if totalHours < 1 {
            return Int(round(totalEarnings / (totalMinutes / 60)))
        } else {
            return Int(round(totalEarnings / totalTime))
        }
    }
    
    private func tagGrossIncome(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let netProfit = matchedSessions.map { Int($0.profit) }.reduce(0, +)
        let totalExpenses = matchedSessions.map { Int($0.expenses) }.reduce(0, +)
        let tournamentBuyIns = matchedSessions.filter({ $0.isTournament == true }).reduce(0) { total, session in
            total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
        }
        let grossIncome = netProfit + totalExpenses + tournamentBuyIns
        return grossIncome
    }
    
    private func tagExpenses(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let taggedTransactions = viewModel.allTransactions.filter({ $0.tags != nil })
        
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        let matchedTransactions = taggedTransactions.filter({ $0.tags?.first == tag && $0.type == .expense })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let totalExpenses = matchedSessions.map({ $0.expenses}).reduce(0, +)
        let tournamentBuyIns = matchedSessions.filter({ $0.isTournament == true }).reduce(0) { total, session in
            total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
        }
        let totalTransactionExpenses = matchedTransactions.map({ $0.amount }).reduce(0, +)

        return totalExpenses + abs(totalTransactionExpenses) + tournamentBuyIns
    }
    
    private func tagTournamentROI(tag: String) -> String {
        
        // Filter sessions with the given tag and ensure they're tournaments
        let matchedSessions = viewModel.allSessions.filter { session in
            session.tags.contains(tag) && session.isTournament
        }
        
        guard !matchedSessions.isEmpty else { return "0%" }
        
        // Calculate total buy-ins (including rebuys)
        let totalBuyIns = matchedSessions.reduce(0) { total, session in
            total + session.buyIn + ((session.rebuyCount ?? 0) * session.buyIn)
        }
        
        // Calculate total winnings (gross)
        let totalWinnings = matchedSessions.reduce(0) { total, session in
            total + session.cashOut
        }
        
        // Calculate ROI
        guard totalBuyIns > 0 else { return "0%" }
        let returnOnInvestment = (Double(totalWinnings) - Double(totalBuyIns)) / Double(totalBuyIns)
        return returnOnInvestment.asPercent()
    }
    
    private func tagDateRange(tag: String) -> (Date, Date)? {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        guard !matchedSessions.isEmpty else { return nil }
        
        let firstDay = matchedSessions.last!.date
        let lastDay = matchedSessions.first!.date
        
        return (firstDay, lastDay)
    }
    
    private func tagActionSold(tag: String) -> Int {
        
        let taggedSessions = viewModel.allSessions.filter({ !$0.tags.isEmpty })
        let matchedSessions = taggedSessions.filter({ $0.tags.first == tag })
        
        let totalAmountOwed = matchedSessions.reduce(0.0) { total, session in
            guard let stakers = session.stakers else { return total }
            
            let totalPercentage = stakers.reduce(0.0) { $0 + $1.percentage }
            let amountOwed = (Double(session.cashOut) + Double(session.bounties ?? 0)) * totalPercentage
            
            return total + amountOwed
        }
        
        return Int(totalAmountOwed)
    }
}

#Preview {
    TagReport()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
