//
//  SessionModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import Foundation
import SwiftUI

struct PokerSession: Hashable, Codable, Identifiable {
    var id = UUID()
    let location: LocationModel
    let game: String
    let stakes: String
    let date: Date
    let profit: Int
    let notes: String
    let startTime: Date
    let endTime: Date
    let expenses: Int?
    let isTournament: Bool?
    let entrants: Int?
    let finish: Int?
    let highHandBonus: Int?
    let buyIn: Int?
    let cashOut: Int?
    let rebuyCount: Int?
    let tournamentSize: String?
    let tournamentSpeed: String?
    let tags: [String]?
    var tournamentDays: Int?
    var startTimeDayTwo: Date?
    var endTimeDayTwo: Date?
    
    // Individual session playing time formatted for Session Detail View
    var playingTIme: String {
        return sessionDuration.abbreviated(duration: self.sessionDuration)
    }
    
    // Individual session duration
    var sessionDuration: DateComponents {

        let dayOneDuration = Calendar.current.dateComponents([.hour, .minute], from: self.startTime, to: self.endTime)
        
        // Check if it's a Multi-Day Tournament
        if let tournamentDays = self.tournamentDays, tournamentDays > 1 {
            if let startTimeDayTwo = self.startTimeDayTwo, let endTimeDayTwo = self.endTimeDayTwo {

                let dayTwoDuration = Calendar.current.dateComponents([.hour, .minute], from: startTimeDayTwo, to: endTimeDayTwo)
                
                // Sum the durations from day one and day two
                let totalMinutes = (dayOneDuration.minute ?? 0) + (dayTwoDuration.minute ?? 0)
                let totalHours = (dayOneDuration.hour ?? 0) + (dayTwoDuration.hour ?? 0) + (totalMinutes / 60)
                let remainingMinutes = totalMinutes % 60
                
                return DateComponents(hour: totalHours, minute: remainingMinutes)
                
            } else {
                return dayOneDuration
            }
        } else {
            return dayOneDuration
        }
    }
    
    // Individual session hourly rate
    var hourlyRate: Int {
        let totalHours = sessionDuration.durationInHours == 0 ? 1 : sessionDuration.durationInHours
        return Int(round(Float(self.profit) / totalHours))
    }
    
    // Individual big blinds won
    var bigBlindsWon: Double {
        guard let lastSlashIndex = stakes.lastIndex(of: "/"),
              let bigBlind = Int(stakes[lastSlashIndex...].trimmingCharacters(in: .punctuationCharacters)) else {
              
            return 0
        }
        
        let bigBlindWin = Float(self.profit) / Float(bigBlind)
        return Double(bigBlindWin)
    }
    
    // Individual big blind per hour rate 
    var bigBlindPerHour: Double {
        guard let lastSlashIndex = stakes.lastIndex(of: "/"),
              let bigBlind = Int(stakes[lastSlashIndex...].trimmingCharacters(in: .punctuationCharacters)) else {
              
            return 0
        }
        
        let totalHours = sessionDuration.durationInHours == 0 ? 1 : sessionDuration.durationInHours
        let bigBlindWin = Float(self.profit) / Float(bigBlind)
        return Double(bigBlindWin) / Double(totalHours)
    }
}

struct BankrollTransaction: Hashable, Identifiable, Codable {
    var id = UUID()
    let date: Date
    let type: TransactionType
    let amount: Int
    let notes: String
    let tags: [String]?
}

enum TransactionType: String, Codable, CaseIterable {
    case deposit, withdrawal, expense
    
    var description: String {
        switch self {
        case .deposit:
            "Deposit"
        case .withdrawal:
            "Withdrawal"
        case .expense:
            "Expense"
        }
    }
}

struct DefaultData {
    
    static let defaultLocation = LocationModel(name: "TBD", localImage: "empty-location", imageURL: "")
}

struct MockData {
    
    static let mockLocation = LocationModel(name: "Encore Boston Harbor", localImage: "encore-header2", imageURL: "")
    static let sampleSession = PokerSession(location: mockLocation,
                                            game: "NL Texas Hold Em",
                                            stakes: "1/3",
                                            date: Date().modifyDays(days: -7),
                                            profit: 1421,
                                            notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam.",
                                            startTime: Date().modifyTime(minutes: -395),
                                            endTime: Date(),
                                            expenses: 12,
                                            isTournament: false,
                                            entrants: nil,
                                            finish: nil,
                                            highHandBonus: nil,
                                            buyIn: 700,
                                            cashOut: 1121,
                                            rebuyCount: nil,
                                            tournamentSize: nil,
                                            tournamentSpeed: nil,
                                            tags: ["Vegas 2024"])
    
    static let sampleTournament = PokerSession(location: mockLocation,
                                               game: "NL Texas Hold Em",
                                               stakes: "",
                                               date: Date().modifyDays(days: -2),
                                               profit: 1200, 
                                               notes: "",
                                               startTime: Date().modifyDays(days: -2),
                                               endTime: Date().modifyDays(days: -2).modifyTime(minutes: 327),
                                               expenses: 400,
                                               isTournament: true,
                                               entrants: 878,
                                               finish: 40,
                                               highHandBonus: nil,
                                               buyIn: 200,
                                               cashOut: 375,
                                               rebuyCount: 3,
                                               tournamentSize: "MTT",
                                               tournamentSpeed: "Standard",
                                               tags: nil,
                                               tournamentDays: 2,
                                               startTimeDayTwo: Date().modifyDays(days: -1),
                                               endTimeDayTwo: Date())
    
    static let allLocations = [
        LocationModel(name: "MGM Springfield", localImage: "mgmspringfield-header", imageURL: ""),
        LocationModel(name: "Encore Boston Harbor", localImage: "encore-header2", imageURL: ""),
        LocationModel(name: "Bellagio Hotel & Casino", localImage: "bellagio-header", imageURL: ""),
        LocationModel(name: "The Lodge", localImage: "thelodge-header", imageURL: "")
        
    ]
    
    static let allSessions = [
        PokerSession(location: allLocations[2],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -12),
                     profit: 327,
                     notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 115),
                     expenses: 0,
                     isTournament: false,
                     entrants: nil,
                     finish: nil,
                     highHandBonus: nil,
                     buyIn: nil,
                     cashOut: nil,
                     rebuyCount: nil,
                     tournamentSize: nil,
                     tournamentSpeed: nil,
                     tags: ["Vegas 2024"]),

        PokerSession(location: allLocations[0],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -1),
                     profit: 219,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 290),
                     expenses: 10,
                     isTournament: false,
                     entrants: nil,
                     finish: nil,
                     highHandBonus: nil,
                     buyIn: nil,
                     cashOut: nil,
                     rebuyCount: nil,
                     tournamentSize: nil,
                     tournamentSpeed: nil,
                     tags: nil),
        
        PokerSession(location: allLocations[1],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -4),
                     profit: 175,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 320),
                     expenses: 7,
                     isTournament: true,
                     entrants: 200,
                     finish: nil,
                     highHandBonus: nil,
                     buyIn: nil,
                     cashOut: nil,
                     rebuyCount: nil,
                     tournamentSize: nil,
                     tournamentSpeed: nil,
                     tags: nil),
    ]
    
    static let sampleTransactions = [
        BankrollTransaction(date: Date().modifyDays(days: -7), type: .deposit, amount: 1000, notes: "Starting bankroll", tags: ["My First Tag"]),
        BankrollTransaction(date: Date(), type: .withdrawal, amount: 350, notes: "Life expenses", tags: nil)
    ]
}
