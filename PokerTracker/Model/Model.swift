//
//  SessionModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import Foundation
import UIKit

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
    
    var dateInterval: String {
        return gameDuration.formattedDuration
    }
    
    // Individual session duration
    var gameDuration: DateComponents {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: self.startTime, to: self.endTime)
        return diffComponents
    }
    
    // Individual session hourly rate
    var hourlyRate: Int {
        let totalHours = gameDuration.durationInHours == 0 ? 1 : gameDuration.durationInHours
        return Int(Float(self.profit) / totalHours)
    }
}

// For some reason using the .currentWindow ext is not working with AppStorage and doesn't save dark/light mode state
class SystemThemeManager {
    static let shared = SystemThemeManager()
    init() {}
    
    func handleTheme(darkMode: Bool, system: Bool) {
        
        guard !system else {
//            UIApplication.shared.currentWindow?.overrideUserInterfaceStyle = .unspecified
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
            return
        }
        
//        UIApplication.shared.currentWindow?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
}

struct MockData {
    
    static let mockLocation = LocationModel(name: "MGM Springfield", localImage: "mgmspringfield-header", imageURL: "")
    static let sampleSession = PokerSession(location: mockLocation,
                                            game: "NL Texas Hold Em",
                                            stakes: "1/3",
                                            date: Date().modifyDays(days: -7),
                                            profit: 863,
                                            notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                                            startTime: Date(),
                                            endTime: Date().modifyTime(minutes: 95))
    
    static let allLocations = [
        LocationModel(name: "MGM Springfield", localImage: "mgmspringfield-header", imageURL: ""),
        LocationModel(name: "Encore Boston Harbor", localImage: "encore-header", imageURL: ""),
        LocationModel(name: "Boston Billiard Club", localImage: "boston-billiards-header", imageURL: ""),
        LocationModel(name: "The Brook", localImage: "brook-header", imageURL: ""),
        LocationModel(name: "Foxwoods Resort & Casino", localImage: "foxwoods-header", imageURL: ""),
        LocationModel(name: "Mohegan Sun Casino", localImage: "mohegan-sun-header", imageURL: ""),
        LocationModel(name: "Rivers Casino & Resort", localImage: "rivers-header", imageURL: "")
    ]
    
    static let allSessions = [
        PokerSession(location: allLocations[5],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -7),
                     profit: 325,
                     notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 115)),

        PokerSession(location: allLocations[1],
                     game: "NL Texas Hold Em",
                     stakes: "1/3",
                     date: Date().modifyDays(days: -2),
                     profit: 225,
                     notes: "MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 95)),

        PokerSession(location: allLocations[2],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -45),
                     profit: 450,
                     notes: "Hero in CO, MP & LP limp I raise $15, Villain is on BTN (younger kid, stack around $550-$600) and he 3! to $45, we call. ($94) Flop is KsQh9h. I check, he bets $35, we call. ($160) Turn is Ac. I check again, Villain pauses a moment and puts in $100. We have about $320 left. Hero???",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 80)),

        PokerSession(location: allLocations[3],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -1),
                     profit: 210,
                     notes: "MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 365)),
        
        PokerSession(location: allLocations[0],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -36),
                     profit: -255,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 340)),

        PokerSession(location: allLocations[0],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -90),
                     profit: 219,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 290)),
        
        PokerSession(location: allLocations[4],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -4),
                     profit: 175,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 320)),
        
        PokerSession(location: allLocations[3],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -400),
                     profit: 557,
                     notes: "Hero in CO, MP & LP limp I raise $15, Villain is on BTN (younger kid, stack around $550-$600) and he 3! to $45, we call. ($94) Flop is KsQh9h. I check, he bets $35, we call. ($160) Turn is Ac. I check again, Villain pauses a moment and puts in $100. We have about $320 left. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 320)),
        
        PokerSession(location: allLocations[5],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -1000),
                     profit: 175,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 324)),
        
        PokerSession(location: allLocations[6],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -1003),
                     profit: -100,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 220)),
    ]
    
    static let mockDataCoordinates: [Point] = [
        .init(x: 1, y: 5),
        .init(x: 2, y: 4),
        .init(x: 3, y: 10),
        .init(x: 4, y: 6),
        .init(x: 5, y: 9),
        .init(x: 6, y: 12),
        .init(x: 7, y: 14),
        .init(x: 8, y: 11),
    ]
}
