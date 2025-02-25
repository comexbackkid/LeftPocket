//
//  MockData.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/23/25.
//

import Foundation

struct MockData {
    
    static let mockLocation = LocationModel_v2(name: "Encore Boston Harbor", localImage: "encore-header2")
    static let mockLocation2 = LocationModel_v2(name: "Turning Stone Casino", localImage: "turningstone-header")
    static let mockLocation3 = LocationModel_v2(name: "MGM Springfield")
    static let mockStakerOne = Staker(name: "Steve Gallant", percentage: 0.20)
    static let mockStakerTwo = Staker(name: "Ryan Nash", percentage: 0.10)
    static let sampleSession = PokerSession_v2(location: mockLocation, date: Date().modifyDays(days: -7), startTime: Date().modifyTime(minutes: -395), endTime: Date(), game: "NL Texas Hold Em", stakes: "1/3", buyIn: 700, cashOut: 1121, profit: 421, expenses: 12, notes: "We kicked butt! Lots of text here to run a text wrapping issue while exporting a share iamge.", tags: ["Vegas Trip 2024"], highHandBonus: 0, handsPerHour: nil, isTournament: false, rebuyCount: nil, bounties: nil, tournamentSize: nil, tournamentSpeed: nil, entrants: nil, finish: nil, tournamentDays: nil, startTimeDayTwo: nil, endTimeDayTwo: nil, stakers: nil)
    
    static let sampleSessionTwo = PokerSession_v2(location: mockLocation, date: Date().modifyDays(days: -12), startTime: Date().modifyDays(days: -12).modifyTime(minutes: -395), endTime: Date(), game: "NL Texas Hold Em", stakes: "1/3", buyIn: 300, cashOut: 100, profit: -200, expenses: 40, notes: "Not great, Bob!", tags: [], highHandBonus: 0, handsPerHour: nil, isTournament: false, rebuyCount: nil, bounties: nil, tournamentSize: nil, tournamentSpeed: nil, entrants: nil, finish: nil, tournamentDays: nil, startTimeDayTwo: nil, endTimeDayTwo: nil, stakers: nil)
    
    static let sampleTournament = PokerSession_v2(location: mockLocation, date: Date().modifyDays(days: -2), startTime: Date().modifyDays(days: -3), endTime: Date().modifyDays(days: -3).modifyTime(minutes: 327), game: "NL Texas Hold Em", stakes: "", buyIn: 200, cashOut: 1400, profit: 1200, expenses: 0, notes: "", tags: [], highHandBonus: 0, handsPerHour: nil, isTournament: true, rebuyCount: nil, bounties: nil, tournamentSize: "MTT", tournamentSpeed: "Standard", entrants: 312, finish: 10, tournamentDays: 3, startTimeDayTwo: Date().modifyDays(days: -2), endTimeDayTwo: Date().modifyDays(days: -2).modifyTime(minutes: 247), stakers: [mockStakerOne, mockStakerTwo])
    
    static let allSessions = [sampleSession, sampleSessionTwo]
    
    static let sampleTransactions = [
        BankrollTransaction(date: Date().modifyDays(days: -7), type: .deposit, amount: 1000, notes: "Starting bankroll", tags: ["My First Tag"]),
        BankrollTransaction(date: Date(), type: .expense, amount: 77, notes: "Dinner", tags: nil)
    ]
    
    static let mockLocations = [mockLocation, mockLocation2, mockLocation3]
}
