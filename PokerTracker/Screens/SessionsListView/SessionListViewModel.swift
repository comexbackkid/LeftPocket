//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI

class SessionsListViewModel: ObservableObject {

    @Published var uniqueLocations: [String] = []
    @Published var sessions: [PokerSession] = [] {
        didSet {
            saveSessions()
            filterByDate()
        }
    }
    
    @Published var sortedSessions: [PokerSession] = []
    
    init() {
        getSessions()
        filterByDate()
    }
    
    // Loads all sessions from UserDefaults upon app launch
    func getSessions() {
        guard
            let data = UserDefaults.standard.data(forKey: "sessions_list"),
            let savedSessions = try? JSONDecoder().decode([PokerSession].self, from: data)
        else { return }
        
        self.sessions = savedSessions
        //        let newSessions = MockData.allSessions
        //        sessions.append(contentsOf: newSessions)
    }
    
    func filterByDate() {
        sortedSessions = sessions.sorted(by: { $0.date > $1.date })
        uniqueLocations = Array(Set(sessions.map { $0.location }))
        }
    
    // Calculate current bankroll
    func tallyBankroll() -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let profits = sessions.map { $0.profit }
        let intArray = profits.map { Int($0)}
        let bankroll = intArray.reduce(0, +)
        return bankroll
    }
    
    // Creates an array of our running, cumulative bankroll for use with SwiftUICharts
    func chartArray() -> [Double] {
        let profitsArray = sessions.map { Double($0.profit) }
        var cumBankroll = [Double]()
        var runningTotal = 0.0
        
        for value in profitsArray {
            runningTotal += value
            cumBankroll.append(runningTotal)
        }
        return cumBankroll
    }
    
    // Bar Chart displaying weekday profit totals
    func dailyChart() -> [(String, Int)] {
        let sunday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Sunday" }).map({ $0.profit }).reduce(0,+)
        let monday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Monday" }).map({ $0.profit }).reduce(0,+)
        let tuesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Tuesday" }).map({ $0.profit }).reduce(0,+)
        let wednesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Wednesday" }).map({ $0.profit }).reduce(0,+)
        let thursday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Thursday" }).map({ $0.profit }).reduce(0,+)
        let friday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Friday" }).map({ $0.profit }).reduce(0,+)
        let saturday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Saturday" }).map({ $0.profit }).reduce(0,+)
        return [("Sun", sunday), ("Mon", monday), ("Tues", tuesday), ("Wed", wednesday), ("Thurs", thursday), ("Fri", friday), ("Sat", saturday)]
    }
    
    // Function that adds a new session to our SessionsListView from NewSessionView
    func addSession(location: String,
                    game: String,
                    stakes: String,
                    date: Date,
                    profit: Int,
                    notes: String,
                    imageName: String,
                    startTime: Date, endTime: Date) {
        
        let imageName = imageFromLocationDictionary[location] ?? ""
        let newSession = PokerSession(location: location,
                                      game: game,
                                      stakes: stakes,
                                      date: date,
                                      profit: profit,
                                      notes: notes,
                                      imageName: imageName,
                                      startTime: startTime, endTime: endTime)
        sessions.append(newSession)
    }
    
    // Saves the list of sessions into UserDefaults
    func saveSessions() {
        if let encodedData = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encodedData, forKey: "sessions_list")
        }
    }
    
    // Adds up total number of profitable sessions
    func numOfCashes() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let profitableSessions = sessions.filter { session in
            return session.profit > 0
        }
        return profitableSessions.count
    }
    
    // Calculate total hourly earnings rate for MetricsView
    func hourlyRate() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let hoursArray = sessions.map { Int($0.gameDuration.hour ?? 0) }
        let totalHours = hoursArray.reduce(0, +)
        return tallyBankroll() / totalHours
    }
    
    // Calculate average session duration for MetricsView
    func avgDuration() -> String {
        guard !sessions.isEmpty else { return "0" }
        let hoursArray: [Int] = sessions.map { $0.gameDuration.hour ?? 0 }
        let minutesArray: [Int] = sessions.map { $0.gameDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +) / sessions.count
        let totalMinutes = minutesArray.reduce(0, +) / sessions.count
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.formattedDuration
    }
    
    // Calculate average profit per session
    func avgProfit() -> Int {
        guard !sessions.isEmpty else { return 0 }
        return tallyBankroll() / sessions.count
    }
    
    // Total hours played from all sessions
    func totalHoursPlayed() -> String {
        guard !sessions.isEmpty else { return "0" }
        let hoursArray: [Int] = sessions.map { $0.gameDuration.hour ?? 0 }
        let minutesArray: [Int] = sessions.map { $0.gameDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +) / sessions.count
        let totalMinutes = minutesArray.reduce(0, +) / sessions.count
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.totalHours(duration: dateComponents)
    }
    
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    // Dictionary that pulls the selected venue and links it to correct image name
    let imageFromLocationDictionary = [
        "Encore Boston Harbor" : "encore-header",
        "Chaser's Poker Room" : "chasers-header",
        "Boston Billiards Club" : "boston-billiards-header",
        "The Brook" : "brook-header",
        "Foxwoods Resort & Casino" : "foxwoods-header"
    ]
}


