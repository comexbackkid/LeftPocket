//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI
import WidgetKit

class SessionsListViewModel: ObservableObject {
    
    @Published var uniqueStakes: [String] = []
    @Published var locations: [LocationModel] = DefaultLocations.allLocations {
        didSet {
            saveLocations()
        }
    }
    
    @Published var sessions: [PokerSession] = [] {
        didSet {
            saveSessions()
            uniqueStakes = Array(Set(sessions.map { $0.stakes }))
            writeToWidget()
        }
    }
    
    init() {
//        getMockSessions()
        getSessions()
        getLocations()
    }
    
    // MARK: WIDGET FUNCTIONS
    
    func writeToWidget() {
        guard let defaults = UserDefaults(suiteName: AppGroup.bankrollSuite) else {
            print("Unable to write to User Defaults!")
            return
        }

        defaults.set(self.tallyBankroll(), forKey: AppGroup.bankrollKey)
        defaults.set(self.sessions.first?.profit ?? 0, forKey: AppGroup.lastSessionKey)
        defaults.set(self.hourlyRate(), forKey: AppGroup.hourlyKey)
        defaults.set(self.sessions.count, forKey: AppGroup.totalSessionsKey)

        guard let chartData = try? JSONEncoder().encode(self.chartCoordinates()) else {
            print("Error writing chart data")
            return
        }

        defaults.set(chartData, forKey: AppGroup.chartKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: SAVING & LOADING APP DATA
    
    var sessionsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sessions.json")
    }
    
    var locationsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("locations.json")
    }
    
    // Saves the list of sessions with FileManager
    func saveSessions() {
        do {
            if let encodedData = try? JSONEncoder().encode(sessions) {
                try? FileManager.default.removeItem(at: sessionsPath)
                try encodedData.write(to: sessionsPath)
            }
        } catch {
            print("Failed to write out sessions \(error)")
        }
    }
    
    // Loads all sessions from FileManager upon app launch
    func getSessions() {
        guard
            let data = try? Data(contentsOf: sessionsPath),
            let savedSessions = try? JSONDecoder().decode([PokerSession].self, from: data)
        else { return }
        
        self.sessions = savedSessions
    }
    
    // Saves the list of locations the user has created with FileManager
    func saveLocations() {
        do {
            if let encodedData = try? JSONEncoder().encode(locations) {
                try? FileManager.default.removeItem(at: locationsPath)
                try encodedData.write(to: locationsPath)
            }
        } catch {
            print("Failed to write out locations, \(error)")
        }
    }
    
    // Function to delete from user's list of Locations from the Settings screen
    func delete(_ location: LocationModel) {
        if let index = locations.firstIndex(where: { $0.id == location.id })
        {
            locations.remove(at: index)
            saveLocations()
        }
    }
    
    // Loads the locations the user has created upon app launch
    func getLocations() {
        guard
            let data = try? Data(contentsOf: locationsPath),
            let savedLocations = try? JSONDecoder().decode([LocationModel].self, from: data)
        else { return }
        
        self.locations = savedLocations
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
    
    // MARK: MOCK DATA FOR PREVIEW & TESTING
    
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
    
    // MARK: CALCULATIONS & DATA PRESENTATION
    
    // Calculate current bankroll
    func tallyBankroll() -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        let bankroll = sessions.map { Int($0.profit) }.reduce(0, +)
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
    
    // Converts our profit data into coordinates tuples for charting
    func chartCoordinates() -> [Point] {
        return chartArray().enumerated().map({Point(x:CGFloat($0.offset), y: $0.element)})
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
    
    // Simply counts how many sessions played by year. Used in Study section
    func sessionsPerYear(year: String) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let count = sessions.filter({ $0.date.getYear() == year })
        return count.count
    }
    
    // Adds up total number of profitable sessions
    func numOfCashes() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let profitableSessions = sessions.filter { $0.profit > 0 }
        return profitableSessions.count
    }
    
    // Returns percentage of winning seessions
    func winRate() -> String {
        guard !sessions.isEmpty else { return "%0" }
        let winPercentage = Double(numOfCashes()) / Double(sessions.count)
        return winPercentage.asPercent()
    }
    
    // Calculate total hourly earnings rate for MetricsView
    func hourlyRate() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let totalHours = sessions.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
        let totalMinutes = Float(sessions.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
        
        if totalHours < 1 {
            return Int(Float(tallyBankroll()) / (totalMinutes / 60))
        } else {
            return tallyBankroll() / totalHours
        }
        
    }
    
    // Calculate average session duration for MetricsView
    func avgDuration() -> String {
        guard !sessions.isEmpty else { return "0" }
        let hoursArray: [Int] = sessions.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessions.map { $0.sessionDuration.minute ?? 0 }
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
        let hoursArray: [Int] = sessions.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessions.map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +)
        let totalMinutes = minutesArray.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    // Gets the Year from very first session played. Used in Metrics View
    func yearRangeFirst() -> String {
        guard !sessions.isEmpty else { return "0" }
        let year = sessions.sorted(by: { $0.date > $1.date })
        return year.reversed()[0].date.getYear()
    }
    
    // Gets the Year from most recent session played. Used in Metrics View
    func yearRangeRecent() -> String {
        
        guard !sessions.isEmpty else { return "0" }
        let year = sessions.sorted(by: { $0.date > $1.date })
        return year[0].date.getYear()
    }
    
    // MARK: CALCULATIONS FOR YEAR-END-SUMMARY VIEW
    
    func bankrollByYear(year: String) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let bankroll = sessions.filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
        return bankroll
    }
    
    func hourlyByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let hoursArray = sessions.filter({ $0.date.getYear() == year }).map { Int($0.sessionDuration.hour ?? 0) }
        let minutesArray = sessions.filter({ $0.date.getYear() == year }).map { Int($0.sessionDuration.minute ?? 0) }
        let totalHours = hoursArray.reduce(0,+)
        let totalMinutes = Float(minutesArray.reduce(0, +))
        
        if totalHours < 1 {
            return Int(Float(bankrollByYear(year: year)) / (totalMinutes / 60))
        } else {
            return bankrollByYear(year: year) / totalHours
        }
    }
    
    func hourlyByLocation(venue: String, total: Int) -> Int {
        guard !sessions.filter({ $0.location.name == venue }).isEmpty else { return 0 }
        let totalHours = sessions.filter({ $0.location.name == venue }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
        return total / totalHours
    }
    
    func hourlyByStakes(stakes: String, total: Int) -> Int {
        guard !sessions.filter({$0.stakes == stakes}).isEmpty else { return 0 }
        let totalHours = sessions.filter({ $0.stakes == stakes }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
        return total / totalHours
    }
    
    func avgProfitByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        return bankrollByYear(year: year) / sessions.filter({ $0.date.getYear() == year }).count
    }
    
    func hoursPlayedByYear(year: String) -> String {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return "0" }
        let hoursArray: [Int] = sessions.filter({ $0.date.getYear() == year }).map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessions.filter({ $0.date.getYear() == year }).map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +)
        let totalMinutes = minutesArray.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    func totalExpenses() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let expenses = sessions.map { $0.expenses ?? 0 }.reduce(0,+)
        return expenses
    }
    
    func totalExpensesByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let expenses = sessions.filter({ $0.date.getYear() == year }).map { $0.expenses ?? 0 }.reduce(0,+)
        return expenses
    }
    
    func numOfCashesByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let profitableSessions = sessions.filter({ $0.date.getYear() == year }).filter { $0.profit > 0 }
        return profitableSessions.count
    }
    
    func winRateByYear(year: String) -> String {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return "%0" }
        let wins = Double(numOfCashesByYear(year: year))
        let sessions = Double(sessionsPerYear(year: year))
        let winPercentage = wins / sessions
        return winPercentage.asPercent()
        
    }
    
    // MARK: CHART FUNCTIONS
    
    func yearlyChartArray(year: String) -> [Double] {
        let profitsArray = sessions.filter({ $0.date.getYear() == year }).map { Double($0.profit) }
        var cumBankroll = [Double]()
        var runningTotal = 0.0
        cumBankroll.append(0.0)
        
        for value in profitsArray.reversed() {
            runningTotal += value
            cumBankroll.append(runningTotal)
        }
        return cumBankroll
    }
    
    func yearlyChartCoordinates(year: String) -> [Point] {
        return yearlyChartArray(year: year).enumerated().map({Point(x:CGFloat($0.offset), y: $0.element)})
    }
    
    // MARK: FILTERING OPTIONS IN METRICS VIEW
    
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
                    startTime: Date, endTime: Date,
                    expenses: Int) {
        
        let newSession = PokerSession(location: location,
                                      game: game,
                                      stakes: stakes,
                                      date: date,
                                      profit: profit,
                                      notes: notes,
                                      startTime: startTime, endTime: endTime,
                                      expenses: expenses)
        sessions.append(newSession)
        sessions.sort(by: {$0.date > $1.date})
    }
    

    
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let daysOfWeekAbr = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}
