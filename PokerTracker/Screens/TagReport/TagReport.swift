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
    
    var body: some View {
        
        ScrollView {
            
            title
            
            VStack (spacing: 12) {
                
                tagSelection
                
                Divider().padding(.vertical)
                
                toplineIncome
                
                Divider().padding(.vertical)
                
                detailedIncome
                
            }
            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
            .lineSpacing(2.5)
            .padding(30)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        }
        .background(Color.brandBackground)
        .accentColor(.brandPrimary)
    }
    
    var title: some View {
        
        HStack {
            Text("Trip Report")
                .titleStyle()
                .padding(.top, -37)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var tagSelection: some View {
        
        HStack {
            Text("Tag Selection")
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
            
            VStack (spacing: 5) {
                
                HStack {
                    Text("Gross Income")
                    
                    Spacer()
                    Text(400, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                        .profitColor(total: 400)
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
                Text(150, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(150 > 0 ? .red : Color(.systemGray))
            }
            
            HStack {
                Text("Net Profit")
                
                Spacer()
                
                Text(220, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: 220)
            }
        }
    }
    
    var detailedIncome: some View {
        
        VStack (spacing: 12) {
            
            let sessionCount = tagSessionCount(tag: tagsFilter)
            let hoursPlayed = tagTotalHours(tag: tagsFilter)
            let winRatio = tagWinRatio(tag: tagsFilter)
            let highhands = tagHighHands(tag: tagsFilter)
            let bestSession = tagBestSession(tag: tagsFilter)
            let profitPerSession = tagProfitPerSession(tag: tagsFilter)
            
            HStack {
                Text("Hourly Rate")
                
                Spacer()
                
                Text(220, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: 220)
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
                
                Text(highhands, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: highhands)
            }
            
            HStack {
                Text("Win Ratio")
                
                Spacer()
                
                Text(winRatio)
                    
            }
            
            HStack {
                Text("No. of Sessions")
                
                Spacer()
                
                Text("\(sessionCount)")
            }
            
            HStack {
                Text("Tournament ROI")
                
                Spacer()
                
                Text(220, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: 220)
            }
            
            HStack {
                Text("Hours Played")
                
                Spacer()
                
                Text(hoursPlayed)
                    
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
}

#Preview {
    TagReport()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
