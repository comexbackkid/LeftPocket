//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI

// Because this class is of type "ObservableObject," we can monitor changes in our other views
class SessionsListModel: ObservableObject {
    
    @Published var sessions: [PokerSession] = []
    
    func tallyBankroll() -> Int {
        let profits = sessions.map { $0.profit }
        let intArray = profits.map { Int($0)!}
        let bankroll = intArray.reduce(0, +)
        return bankroll
        }
    
    init() {
        getSessions()
    }
    
    func getSessions() {
        let newSessions = MockData.allSessions
        sessions.append(contentsOf: newSessions)
    }
    
    
// This is really sloppy & ghetto. Fix how it determines which image to use.
    
    func addSession(location: String, game: String, stakes: String, date: String, profit: String, notes: String, imageName: String, startTime: Date, endTime: Date) {
        
        switch location {
        case "Encore Boston Harbor":
            let imageName: String = "encore-header"
            let newSession = PokerSession(location: location, game: game, stakes: stakes, date: date, profit: profit, notes: notes, imageName: imageName, startTime: startTime, endTime: endTime)
            sessions.append(newSession)
            
        case "Chaser's Poker Room":
            let imageName: String = "chasers-header"
            let newSession = PokerSession(location: location, game: game, stakes: stakes, date: date, profit: profit, notes: notes, imageName: imageName, startTime: startTime, endTime: endTime)
            
        case "Boston Billiards Club":
            let imageName: String = "boston-billiards-header"
            let newSession = PokerSession(location: location, game: game, stakes: stakes, date: date, profit: profit, notes: notes, imageName: imageName, startTime: startTime, endTime: endTime)
            
        default:
            let imageName: String = ""
            let newSession = PokerSession(location: location, game: game, stakes: stakes, date: date, profit: profit, notes: notes, imageName: imageName, startTime: startTime, endTime: endTime)
        }
    }
}
