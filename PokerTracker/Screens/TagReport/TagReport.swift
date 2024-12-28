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
    
    var imageGenerator: Image {
        
        let sessions = viewModel.sessions.filter({ $0.tags?.first == tagsFilter })
        let firstLocation = sessions.last?.location
        
        if let photoData = firstLocation?.importedImage, let uiImage = UIImage(data: photoData) {
            
            return Image(uiImage: uiImage)
                
        } else if let localImage = firstLocation?.localImage{
            
            return Image(localImage)
            
        } else {
            
            return Image("defaultlocation-header")
        }
    }
    
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
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .padding(.bottom, 80)
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
            
            Text("Tag Name")
                .bodyStyle()
            
            Spacer()
            
            Menu {
                Picker("Tag Selection", selection: $tagsFilter) {
                    ForEach(viewModel.sessions.compactMap { $0.tags?.first }.filter { !$0.isEmpty }.uniqued(), id: \.self) {
                        Text($0.capitalized).tag($0)
                    }
                }
            } label: {
                
                if tagsFilter.isEmpty {
                    Text("Please select ›")
                        .bodyStyle()
                } else {
                    Text(tagsFilter.capitalized)
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
            
            VStack (spacing: 5) {
                
                HStack {
                    Text("Gross Income")
                    
                    Spacer()
                    Text(grossIncome, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                        .profitColor(total: grossIncome)
                }
                
                HStack {
                    Text("(Includes High Hands)")
                        .captionStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                }
            }
            
            HStack {
                Text("Expenses")
                
                Spacer()
                Text(expenses, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(expenses > 0 ? .red : Color(.systemGray))
            }
            
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
    
    private func tagSessionCount(tag: String) -> Int {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        return matchedSessions.count
    }
    
    private func tagTotalHours(tag: String) -> String {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return "0" }
        
        let hoursArray: [Int] = matchedSessions.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = matchedSessions.map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +)
        let totalMinutes = minutesArray.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    private func tagWinRatio(tag: String) -> String {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return "0%" }
        
        let wins = Double(matchedSessions.filter({ $0.profit > 0 }).count)
        let sessions = Double(matchedSessions.count)
        let winRatio = wins / sessions
        return winRatio.asPercent()
    }
    
    private func tagHighHands(tag: String) -> Int {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let highHandsTotal = matchedSessions.map({ $0.highHandBonus ?? 0 }).reduce(0, +)
        return highHandsTotal
    }
    
    private func tagBestSession(tag: String) -> Int {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        guard let bestSession = matchedSessions.map({ $0.profit }).max(by: { $0 < $1 }) else {
            return 0
        }
        
        return bestSession
    }
    
    private func tagProfitPerSession(tag: String) -> Int {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let profit = matchedSessions.map({ $0.profit }).reduce(0, +)
        let count = matchedSessions.count
        return profit / count
    }
    
    private func tagHourlyRate(tag: String) -> Int {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
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
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let netProfit = matchedSessions.map { Int($0.profit) }.reduce(0, +)
        let totalExpenses = matchedSessions.map { Int($0.expenses ?? 0) }.reduce(0, +)
        let grossIncome = netProfit + totalExpenses
        return grossIncome
    }
    
    private func tagExpenses(tag: String) -> Int {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return 0 }
        
        let totalExpenses = matchedSessions.map({ $0.expenses ?? 0 }).reduce(0, +)
        return totalExpenses
    }
    
    private func tagTournamentROI(tag: String) -> String {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag && $0.isTournament == true })
        guard !matchedSessions.isEmpty else { return "0%" }
        
        let totalBuyIns = matchedSessions.map({ $0.expenses! }).reduce(0,+)
        let totalWinnings = matchedSessions.map({ $0.profit + $0.expenses! }).reduce(0,+)
        let returnOnInvestment = (Double(totalWinnings) - Double(totalBuyIns)) / Double(totalBuyIns)
        return returnOnInvestment.asPercent()
    }
    
    private func tagDateRange(tag: String) -> (Date, Date)? {
        
        let taggedSessions = viewModel.sessions.filter({ $0.tags != nil })
        let matchedSessions = taggedSessions.filter({ $0.tags?.first == tag })
        guard !matchedSessions.isEmpty else { return nil }
        
        let firstDay = matchedSessions.last!.date
        let lastDay = matchedSessions.first!.date
        
        return (firstDay, lastDay)
    }
}

#Preview {
    TagReport()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
