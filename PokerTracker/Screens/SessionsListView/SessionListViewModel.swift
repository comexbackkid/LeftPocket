//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI

class SessionsListViewModel: ObservableObject {
    
    @Published var uniqueStakes: [String] = []
    @Published var locations: [LocationModel] = [] {
        didSet {
            saveLocations()
        }
    }
    
    @Published var sessions: [PokerSession] = [] {
        didSet {
            saveSessions()
           
            // Do these need if let or guard let statements?
            uniqueStakes = Array(Set(sessions.map { $0.stakes }))
        }
    }
    
    init () {
//        getMockSessions()
//        getMockLocations()
        getSessions()
        getLocations()
    }
    
    // Loads all sessions from UserDefaults upon app launch
    func getSessions() {
        guard
            let data = UserDefaults.standard.data(forKey: "sessions_list"),
            let savedSessions = try? JSONDecoder().decode([PokerSession].self, from: data)
        else { return }
        
        self.sessions = savedSessions
    }
    
    // Loading fake data for Preview Provider
    func getMockSessions() {
        let fakeSessions = MockData.allSessions.sorted(by: {$0.date > $1.date})
        self.sessions = fakeSessions
        
    }
    
    // Loading fake locations so our filtered views can work correctly
    func getMockLocations() {
        let fakeLocations = MockData.allLocations
        self.locations = fakeLocations
    }
    
    // Saves the list of sessions into UserDefaults
    func saveSessions() {
        if let encodedData = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encodedData, forKey: "sessions_list")
        }
    }
    
    // Saves a list of locations the user has created
    func saveLocations() {
        if let encodedData = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encodedData, forKey: "locations_list")
        }
    }
    
    // Loads the locations the user has created upon app launch
    func getLocations() {
        guard
            let data = UserDefaults.standard.data(forKey: "locations_list"),
            let savedLocations = try? JSONDecoder().decode([LocationModel].self, from: data)
        else { return }
        
        self.locations = savedLocations
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
        cumBankroll.append(0.0)
        
        for value in profitsArray.reversed() {
            runningTotal += value
            cumBankroll.append(runningTotal)
        }
        return cumBankroll
    }
    
    // Custom designed Bar Chart weekday profit totals
    func dailyBarChart() -> [Int] {
        let sunday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Sunday" }).map({ $0.profit }).reduce(0,+)
        let monday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Monday" }).map({ $0.profit }).reduce(0,+)
        let tuesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Tuesday" }).map({ $0.profit }).reduce(0,+)
        let wednesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Wednesday" }).map({ $0.profit }).reduce(0,+)
        let thursday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Thursday" }).map({ $0.profit }).reduce(0,+)
        let friday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Friday" }).map({ $0.profit }).reduce(0,+)
        let saturday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Saturday" }).map({ $0.profit }).reduce(0,+)
        return [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
    }
    
    // MARK: FILTERING OPTIONS
    
    func sessionsByLocation(_ location: String) -> [PokerSession] {
        sessions.filter({ $0.location.name == location })
    }
    
    func profitByLocation(_ location: String) -> Int {
        return sessionsByLocation(location).reduce(0) { $0 + $1.profit }
    }
    
    func sessionsByDayOfWeek(_ day: String) -> [PokerSession] {
        sessions.filter({ $0.date.dayOfWeek(day: $0.date) == day })
    }
    
    func profitByDayOfWeek(_ day: String) -> Int {
        return sessionsByDayOfWeek(day).reduce(0) { $0 + $1.profit }
    }
    
    func sessionsByMonth(_ month: String) -> [PokerSession] {
        sessions.filter({ $0.date.monthOfYear(month: $0.date) == month })
    }
    
    func profitByMonth(_ month: String) -> Int {
        return sessionsByMonth(month).reduce(0) { $0 + $1.profit }
    }
    
    func sessionsByStakes(_ stakes: String) -> [PokerSession] {
        sessions.filter({ $0.stakes == stakes })
    }
    
    func profitByStakes(_ stakes: String) -> Int {
        return sessionsByStakes(stakes).reduce(0) { $0 + $1.profit }
    }
    
    // Function that adds a new session to our SessionsListView from NewSessionView
    func addSession(location: LocationModel,
                    game: String,
                    stakes: String,
                    date: Date,
                    profit: Int,
                    notes: String,
                    startTime: Date, endTime: Date) {
        
        let newSession = PokerSession(location: location,
                                      game: game,
                                      stakes: stakes,
                                      date: date,
                                      profit: profit,
                                      notes: notes,
                                      startTime: startTime, endTime: endTime)
        sessions.append(newSession)
        sessions.sort(by: {$0.date > $1.date})
    }
    
    // Adds a new Location to the app
    func addLocation(name: String,
                     localImage: String,
                     imageURL: String) {
        
        let newLocation = LocationModel(name: name,
                                        localImage: localImage,
                                        imageURL: imageURL)
        
        locations.append(newLocation)
    }
    
    // Adds up total number of profitable sessions
    func numOfCashes() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let profitableSessions = sessions.filter { $0.profit > 0 }
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
    let daysOfWeekAbr = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}
