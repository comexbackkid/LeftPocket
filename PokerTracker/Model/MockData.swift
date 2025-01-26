//
//  MockData.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/23/25.
//

import Foundation

struct MockData {
    
    static let mockLocation = LocationModel_v2(name: "Encore Boston Harbor", localImage: "encore-header2")
    static let sampleSession = PokerSession_v2(location: mockLocation, date: Date().modifyDays(days: -7), startTime: Date().modifyTime(minutes: -395), endTime: Date(), game: "NL Texas Hold Em", stakes: "1/3", buyIn: 700, cashOut: 1121, profit: 421, expenses: 12, notes: "We kicked butt!", tags: ["Vegas Trip 2024"], highHandBonus: 0, isTournament: false, rebuyCount: nil, tournamentSize: nil, tournamentSpeed: nil, entrants: nil, finish: nil, tournamentDays: nil, startTimeDayTwo: nil, endTimeDayTwo: nil)
    
    static let sampleSessionTwo = PokerSession_v2(location: mockLocation, date: Date().modifyDays(days: -12), startTime: Date().modifyDays(days: -12).modifyTime(minutes: -395), endTime: Date(), game: "NL Texas Hold Em", stakes: "1/3", buyIn: 300, cashOut: 100, profit: -200, expenses: 40, notes: "Not great, Bob!", tags: [], highHandBonus: 0, isTournament: false, rebuyCount: nil, tournamentSize: nil, tournamentSpeed: nil, entrants: nil, finish: nil, tournamentDays: nil, startTimeDayTwo: nil, endTimeDayTwo: nil)
    
    static let sampleTournament = PokerSession_v2(location: mockLocation, date: Date().modifyDays(days: -2), startTime: Date().modifyDays(days: -2), endTime: Date().modifyDays(days: -2).modifyTime(minutes: 327), game: "NL Texas Hold Em", stakes: "", buyIn: 200, cashOut: 1400, profit: 1200, expenses: 0, notes: "", tags: [""], highHandBonus: 0, isTournament: true, rebuyCount: 0, tournamentSize: "MTT", tournamentSpeed: "Standard", entrants: 312, finish: 10, tournamentDays: 1, startTimeDayTwo: nil, endTimeDayTwo: nil)
    
    static let allSessions = [sampleSession, sampleSessionTwo]
    
    static let sampleTransactions = [
        BankrollTransaction(date: Date().modifyDays(days: -7), type: .deposit, amount: 1000, notes: "Starting bankroll", tags: ["My First Tag"]),
        BankrollTransaction(date: Date(), type: .expense, amount: 77, notes: "Dinner", tags: nil)
    ]
}
