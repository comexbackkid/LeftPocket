//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI
import WidgetKit

class SessionsListViewModel: ObservableObject {
    
    @Published var alertMessage: String?
    @Published var uniqueStakes: [String] = []
    @Published var stakesProgress: Float = 0.0
    @Published var userStakes: [String] = ["1/2", "1/3", "2/5", "5/10"] {
        didSet {
            saveUserStakes()
        }
    }
    @Published var userCurrency: CurrencyType = .USD
    @Published var lineChartFullScreen = false
    @Published var convertedLineChartData: [Int]?
    @Published var locations: [LocationModel] = DefaultLocations.allLocations {
        didSet {
            saveLocations()
        }
    }
    @Published var sessions: [PokerSession] = [] {
        didSet {
            saveSessions()
            setUniqueStakes()
            writeToWidget()
            updateStakesProgress()
            objectWillChange.send()
        }
    }
    @Published var transactions: [BankrollTransaction] = [] {
        didSet {
            saveTransactions()
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fileAccessAvailable), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        getSessions()
        getTransactions()
        getLocations()
        getUserStakes()
        loadCurrency()
        writeToWidget()
    }
    
    // MARK: SAVING & LOADING APP DATA: SESSIONS, LOCATIONS, STAKES
    
    // We're running this in the event the app gets launched in the background prior to having permissions to read/write data to the file system.
    // What we do is simply check for an error message, and then attempt to load the data again once triggered by the NotificationCenter.
    @objc func fileAccessAvailable() {
        if alertMessage != nil {
            getSessions()
            getLocations()
            getUserStakes()
            alertMessage = nil
        }
    }
    
    var sessionsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sessions.json")
    }
    
    var locationsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("locations.json")
    }
    
    var stakesPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("stakes.json")
    }
    
    var transactionsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("transactions.json")
    }
    
    // Saves the list of sessions with FileManager
    func saveSessions() {
        do {
            if let encodedData = try? JSONEncoder().encode(sessions) {
                try? FileManager.default.removeItem(at: sessionsPath)
                try encodedData.write(to: sessionsPath)
            }
        } catch {
            print("Failed to write out Sessions \(error)")
        }
    }
    
    func saveTransactions() {
        do {
            if let encodedData = try? JSONEncoder().encode(transactions) {
                try? FileManager.default.removeItem(at: transactionsPath)
                try encodedData.write(to: transactionsPath)
            }
        } catch {
            print("Failed to write Transactions. Error: \(error)")
        }
    }
    
    // Loads all sessions from FileManager upon app launch
    func getSessions() {
        do {
            let data = try Data(contentsOf: sessionsPath)
            let savedSessions = try JSONDecoder().decode([PokerSession].self, from: data)
            self.sessions = savedSessions

        } catch {
            print("Failed to load session with error \(error)")
            alertMessage = error.localizedDescription
            return
        }
    }
    
    func getTransactions() {
        do {
            let data = try Data(contentsOf: transactionsPath)
            let savedTransactions = try JSONDecoder().decode([BankrollTransaction].self, from: data)
            self.transactions = savedTransactions
            
        } catch {
            print("Failed to load Transactions with error \(error)")
            alertMessage = error.localizedDescription
            return
        }
    }
    
    // Saves the list of locations the user has created with FileManager
    func saveLocations() {
        do {
            if let encodedData = try? JSONEncoder().encode(locations) {
                try? FileManager.default.removeItem(at: locationsPath)
                try encodedData.write(to: locationsPath)
            }
        } catch {
            print("Failed to save locations, \(error)")
        }
    }
    
    // Saves the list of stakes the user has created, in addition to the 3x defaults
    func saveUserStakes() {
        do {
            if let encodedData = try? JSONEncoder().encode(userStakes) {
                try? FileManager.default.removeItem(at: stakesPath)
                try encodedData.write(to: stakesPath)
            }
        } catch {
            print("Failed to save user's stakes, \(error)")
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
        do {
            let data = try Data(contentsOf: locationsPath)
            let importedLocations = try JSONDecoder().decode([LocationModel].self, from: data)
            self.locations = importedLocations
            
        } catch {
            print("Failed to load saved Locations with error: \(error)")
            alertMessage = error.localizedDescription
        }
    }
    
    // Loads the stakes the user has saved
    func getUserStakes() {
        do {
            let data = try Data(contentsOf: stakesPath)
            let importedStakes = try JSONDecoder().decode([String].self, from: data)
            self.userStakes = importedStakes
            
        } catch {
            print("Failed to load Stakes with error: \(error)")
            alertMessage = error.localizedDescription
        }
    }
    
    // Will merge Default Locations in to the current saved Locations and also keep the same order
    func mergeLocations() {
        var modifiedLocations = self.locations
        
        for newLocation in DefaultLocations.allLocations {
            if !modifiedLocations.contains(newLocation) {
                modifiedLocations.append(newLocation)
            }
        }
        
        self.locations = modifiedLocations
    }
    
    // Adds a new Location to the app
    func addLocation(name: String, localImage: String, imageURL: String, importedImage: Data?) {
        let newLocation = LocationModel(name: name, localImage: localImage, imageURL: imageURL, importedImage: importedImage)
        
        locations.append(newLocation)
    }
    
    func addStakes(_ stakes: String) {
        guard !userStakes.contains(stakes) else {
            return
        }
        
        userStakes.append(stakes)
    }
    
    func setUniqueStakes() {
        let sortedSessions = allCashSessions().sorted(by: { $0.date > $1.date })
        uniqueStakes = Array(Set(sortedSessions.map({ $0.stakes })))
    }
    
    // MARK: LOADING USER'S PREFERRED CURRENCY
    
    func loadCurrency() {
        let defaults = UserDefaults.standard
        
        guard
            let data = defaults.object(forKey: "currencyDefault") as? Data,
            let currency = try? JSONDecoder().decode(CurrencyType.self, from: data)
                
        else { return }
        
        userCurrency = currency
    }
    
    // MARK: CALCULATIONS & DATA PRESENTATION FOR CHARTS & METRICS VIEW
    
    // Simply counts how many sessions played each year
    func sessionsPerYear(year: String) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.filter({ $0.date.getYear() == year }).count
    }
    
    // Returns percentage of winning sessions
    func winRate() -> String {
        guard !allCashSessions().isEmpty else { return "0%" }
        let cashSessions = allCashSessions()
        let winPercentage = Double(numOfCashes()) / Double(cashSessions.count)
        return winPercentage.asPercent()
    }
    
    // MARK: ADDITIONAL CALCULATIONS
    
    func bankrollByYear(year: String, sessionFilter: SessionFilter) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        
        var bankroll: Int {
            switch sessionFilter {
            case .all:
                sessions.filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
            case .cash:
                allCashSessions().filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
            case .tournaments:
                allTournamentSessions().filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
            }
        }

        return bankroll
    }
    
    func winStreak() -> Int {
        var streak = 0
        
        // Iterate through sessions in reverse order (from most recent to oldest)
        for session in sessions {
            if session.profit > 0 {
                // If on a win streak or neutral, increment the streak
                if streak >= 0 {
                    streak += 1
                } else {
                    break // Break if switching from a losing streak
                }
            } else if session.profit < 0 {
                // If on a losing streak or neutral, decrement the streak
                if streak <= 0 {
                    streak -= 1
                } else {
                    break // Break if switching from a win streak
                }
            } else {
                break // Streak ends on a neutral session (profit == 0)
            }
        }
        
        return streak
    }
    
    // MARK: CHARTING FUNCTIONS
    
    func convertToLineChartData() {
        var convertedData: [Int] {
            
            // Start with zero as our initial data point so chart doesn't look goofy
            var originalDataPoint = [0]
            let newDataPoints = calculateCumulativeProfit(sessions: self.sessions, sessionFilter: .all)
            originalDataPoint += newDataPoints
            return originalDataPoint
        }
        
        self.convertedLineChartData = convertedData
    }
    
    // Chart function used to sum up a cumulative array of Integers for Swift Charts X-Axis
    func calculateCumulativeProfit(sessions: [PokerSession], sessionFilter: SessionFilter) -> [Int] {
        
        // We run this so tha twe can just use the Index as our X Axis value. Keeps spacing uniform and neat looking.
        // Then, in chart configuration we just plot along the Index value, and Int is our cumulative profit amount.
        var cumulativeProfit = 0
        
        // Take the cash / tournament filter and assign to this variable
        var filteredSessions: [PokerSession] {
            switch sessionFilter {
            case .all:
                return sessions
            case .cash:
                return sessions.filter({ $0.isTournament == false || $0.isTournament == nil })
            case .tournaments:
                return sessions.filter({ $0.isTournament == true })
            }
        }

        // I'm having to manually sort the sessions array here, even though it's doing it in the Add Session function. Don't know why.
        let result = filteredSessions.sorted(by: { $0.date < $1.date }).map { session -> Int in
            cumulativeProfit += session.profit
            return cumulativeProfit
        }

        return result
    }
    
    // MARK: ADDITIONAL METRICS CARDS
    
    func sessionsByMonth(_ month: String) -> [PokerSession] {
        sessions.filter({ $0.date.monthOfYear(month: $0.date) == month })
    }
    
    func profitByMonth(_ month: String) -> Int {
        return sessionsByMonth(month).reduce(0) { $0 + $1.profit }
    }
    
    func sessionsByStakes(_ stakes: String) -> [PokerSession] {
        sessions.filter({ $0.stakes == stakes })
    }
    
    // Take in the stakes, and feed it which sessions to filter from
    func profitByStakes(stakes: String, sessions: [PokerSession]) -> Int {
        return sessions.filter({ $0.stakes == stakes }).reduce(0) { $0 + $1.profit }
    }
    
    // Function that adds a new session to variable sessions, above, from NewSessionView
    func addSession(location: LocationModel,
                    game: String,
                    stakes: String,
                    date: Date,
                    profit: Int,
                    notes: String,
                    startTime: Date, endTime: Date,
                    expenses: Int,
                    isTournament: Bool,
                    entrants: Int,
                    finish: Int,
                    highHandBonus: Int,
                    buyIn: Int,
                    cashOut: Int,
                    rebuyCount: Int,
                    tournamentSize: String,
                    tournamentSpeed: String,
                    tags: [String]?) {
        
        let newSession = PokerSession(location: location,
                                      game: game,
                                      stakes: stakes,
                                      date: date,
                                      profit: profit,
                                      notes: notes,
                                      startTime: startTime, endTime: endTime,
                                      expenses: expenses,
                                      isTournament: isTournament,
                                      entrants: entrants,
                                      finish: finish,
                                      highHandBonus: highHandBonus,
                                      buyIn: buyIn,
                                      cashOut: cashOut,
                                      rebuyCount: rebuyCount,
                                      tournamentSize: tournamentSize,
                                      tournamentSpeed: tournamentSpeed,
                                      tags: tags
        )
        sessions.append(newSession)
        sessions.sort(by: {$0.date > $1.date})
    }
    
    func addTransaction(date: Date, type: TransactionType, amount: Int, notes: String, tags: [String]?) {
        
        if type == .withdrawal || type == .expense {
            let newAmount = -(amount)
            let newTransaction = BankrollTransaction(date: date, type: type, amount: newAmount, notes: notes, tags: tags)
            transactions.append(newTransaction)
        } else {
            let newTransaction = BankrollTransaction(date: date, type: type, amount: amount, notes: notes, tags: tags)
            transactions.append(newTransaction)
        }
        
        transactions.sort(by: {$0.date > $1.date})
    }
    
    // MARK: WIDGET FUNCTIONS
    
    func writeToWidget() {
        
        guard let defaults = UserDefaults(suiteName: AppGroup.bankrollSuite) else {
            print("Unable to write to User Defaults!")
            return
        }

        defaults.set(self.tallyBankroll(bankroll: .all), forKey: AppGroup.bankrollKey)
        defaults.set(self.sessions.first?.profit ?? 0, forKey: AppGroup.lastSessionKey)
        defaults.set(self.hourlyRate(bankroll: .all), forKey: AppGroup.hourlyKey)
        defaults.set(self.sessions.count, forKey: AppGroup.totalSessionsKey)
        defaults.set(self.userCurrency.rawValue, forKey: AppGroup.currencyKey)
        
        self.convertToLineChartData()
        
        guard let swiftChartData = try? JSONEncoder().encode(self.convertedLineChartData) else {
            print("Error writing chart data")
            return
        }
        defaults.set(swiftChartData, forKey: AppGroup.swiftChartKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: COUNT USER ACTIVITY FOR PAYWALL LOGIC
    
    func sessionsLoggedThisMonth(sessions: [PokerSession]) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        return sessions.filter { session in
            let sessionDate = session.date
            let sessionMonth = calendar.component(.month, from: sessionDate)
            let sessionYear = calendar.component(.year, from: sessionDate)
            return sessionMonth == currentMonth && sessionYear == currentYear
        }.count
    }
    
    // Returns false if the user tries to add a 6th session for the month
    func canLogNewSession() -> Bool {
        let loggedThisMonth = sessionsLoggedThisMonth(sessions: self.sessions)
        return loggedThisMonth < 5
    }
    
    // MARK: MOCK DATA FOR PREVIEW & TESTING
    
    // Loading fake data for Preview Provider
//    func getMockSessions() {
//        let fakeSessions = MockData.allSessions.sorted(by: {$0.date > $1.date})
//        self.sessions = fakeSessions
//    }
    
    // Loading fake locations so our filtered views can work correctly
    func getMockLocations() {
            let fakeLocations = MockData.allLocations
            self.locations = fakeLocations
    }
    
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}

extension SessionsListViewModel {
    
    func allTournamentSessions() -> [PokerSession] {
        return sessions.filter({ $0.isTournament == true })
    }
    
    func allCashSessions() -> [PokerSession] {
        return sessions.filter({ $0.isTournament == false || $0.isTournament == nil })
    }
}
