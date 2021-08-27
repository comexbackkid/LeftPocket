//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI

let imageFromLocationDictionary = [
    "Encore Boston Harbor" : "encore-header",
    "Chaser's Poker Room" : "chasers-header",
    "Boston Billiards Club" : "boston-billiards-header",
]

// Because this class is of type "ObservableObject," we can monitor changes in our other views
class SessionsListModel: ObservableObject {
    
    // TODO:Check how to save in UserDefaults using SwiftUI
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
        
        let imageName = imageFromLocationDictionary[location] ?? ""
        let newSession = PokerSession(location: location, game: game, stakes: stakes, date: date, profit: profit, notes: notes, imageName: imageName, startTime: startTime, endTime: endTime)
        
        sessions.append(newSession)
    }
    
}
