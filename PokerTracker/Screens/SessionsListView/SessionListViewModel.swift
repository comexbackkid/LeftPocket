//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI
import WidgetKit

class SessionsListViewModel: ObservableObject {
    
    // I'm not sure I'm even using this alert... SHOULD probably use it for migration function in case of error
    @Published var alertMessage: String?
    @Published var bankrollProgressRing: Float = 0.0
    @Published var userStakes: [String] = ["1/2", "1/3", "2/5", "5/10"] {
        didSet {
            saveUserStakes()
        }
    }
    @Published var userGameTypes: [String] = ["NL Texas Hold Em", "Pot Limit Omaha", "Seven Card Stud", "Razz", "Mixed"] {
        didSet {
            saveUserGameTypes()
        }
    }
    @Published var userCurrency: CurrencyType = .USD
    @Published var lineChartFullScreen = false
    @Published var convertedLineChartData: [Int]?
    @Published var locations: [LocationModel_v2] = [] {
        didSet {
            saveNewLocations()
        }
    }
    @Published var sessions: [PokerSession_v2] = [] {
        didSet {
            saveNewSessions()
            writeToWidget()
            updateBankrollProgressRing()
            objectWillChange.send()
        }
    }
    @Published var transactions: [BankrollTransaction] = [] {
        didSet {
            saveTransactions()
        }
    }
    @Published var bankrolls: [Bankroll] = [] {
        didSet {
            saveBankrolls()
        }
    }
    
    @AppStorage("userRiskTolerance") var riskRaw: String = UserRiskTolerance.conservative.rawValue
    @AppStorage("multipleBankrollsEnabled") var multipleBankrollsEnabled: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fileAccessAvailable), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        getNewSessions()
        getNewLocations()
        getTransactions()
        getUserStakes()
        getUserCurrency()
        getUserGameTypes()
        writeToWidget()
//        multipleBankrollsEnabled = false
        
        if multipleBankrollsEnabled {
            loadBankrolls()
        }
    }
    
    // MARK: SAVING & LOADING APP DATA: SESSIONS, LOCATIONS, STAKES
    
    /// We're running this in the event the app gets launched in the background prior to having permissions to read/write data to the file system.
    /// What we do is simply check for an error message, and then attempt to load the data again once triggered by the NotificationCenter.
    @objc func fileAccessAvailable() {
        getNewSessions()
        getNewLocations()
        getUserStakes()
        alertMessage = nil
    }
    
    var sessionsPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sessions.json") }
    var newSessionsPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sessions_v2.json") }
    var locationsPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("locations.json") }
    var newLocationsPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("locations_v2.json") }
    var stakesPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("stakes.json") }
    var gameTypePath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("gameTypes.json") }
    var transactionsPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("transactions.json") }
    var bankrollsPath: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("bankrolls.json") }
    
    func saveBankrolls() {
        do {
            let data = try JSONEncoder().encode(bankrolls)
            try? FileManager.default.removeItem(at: bankrollsPath)
            try data.write(to: bankrollsPath)
            
        } catch {
            print("Failed to save bankrolls: \(error)")
        }
    }

    func loadBankrolls() {
        do {
            let data = try Data(contentsOf: bankrollsPath)
            let decoded = try JSONDecoder().decode([Bankroll].self, from: data)
            self.bankrolls = decoded
            
        } catch {
            print("Failed to load bankrolls: \(error)")
        }
    }
    
    func saveNewSessions() {
        do {
            if let encodedData = try? JSONEncoder().encode(sessions) {
                try? FileManager.default.removeItem(at: newSessionsPath)
                try encodedData.write(to: newSessionsPath)
            }
        } catch {
            print("Failed to write out Sessions \(error)")
        }
    }
    
    func getNewSessions() {
        do {
            let data = try Data(contentsOf: newSessionsPath)
            let savedSessions = try JSONDecoder().decode([PokerSession_v2].self, from: data)
            self.sessions = savedSessions
            print("Successfully loaded \(self.sessions.count) sessions.")
            
        } catch {
            print("Failed to load sessions: \(error.localizedDescription)")
            alertMessage = "Could not load your session data."
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
    
    func addNewLocation(name: String, importedImage: String?) {
        let newLocation = LocationModel_v2(name: name, importedImage: importedImage)

        locations.append(newLocation)
    }
    
    func saveNewLocations() {
        do {
            if let encodedData = try? JSONEncoder().encode(locations) {
                try? FileManager.default.removeItem(at: newLocationsPath)
                try encodedData.write(to: newLocationsPath)
            }
        } catch {
            print("Failed to save locations, \(error)")
        }
    }
    
    func getNewLocations() {
        do {
            let data = try Data(contentsOf: newLocationsPath)
            let importedLocations = try JSONDecoder().decode([LocationModel_v2].self, from: data)
            self.locations = importedLocations
            
        } catch {
            print("Failed to load saved Locations with error: \(error)")
            alertMessage = error.localizedDescription
        }
    }
    
    func delete(_ location: LocationModel_v2) {
        if let index = locations.firstIndex(where: { $0.id == location.id })
        {
            locations.remove(at: index)
            saveNewLocations()
        }
    }
    
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
    
    func saveUserGameTypes() {
        do {
            if let encodedData = try? JSONEncoder().encode(userGameTypes) {
                try? FileManager.default.removeItem(at: gameTypePath)
                try encodedData.write(to: gameTypePath)
            }
        } catch {
            print("Failed to save user's game types, \(error)")
        }
    }
    
    func getUserGameTypes() {
        do {
            let data = try Data(contentsOf: gameTypePath)
            let importedGameTypes = try JSONDecoder().decode([String].self, from: data)
            self.userGameTypes = importedGameTypes
            
        } catch {
            print("Failed to load Stakes with error: \(error)")
            alertMessage = error.localizedDescription
        }
    }
    
    func getUserStakes() {
        do {
            let data = try Data(contentsOf: stakesPath)
            let importedStakes = try JSONDecoder().decode([String].self, from: data)
            self.userStakes = importedStakes.sorted()
            
        } catch {
            print("Failed to load Stakes with error: \(error)")
            alertMessage = error.localizedDescription
        }
    }

    func addStakes(_ stakes: String) {
        guard !userStakes.contains(stakes) else {
            return
        }
        
        userStakes.append(stakes)
        userStakes.sort()
    }
    
    /// Potential crash point, we were previously assuming UserDefaults had a currencyDefault set
    /// Now, we're providing a fallback value of USD to be safe
    func getUserCurrency() {
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: "currencyDefault"),
           let currency = try? JSONDecoder().decode(CurrencyType.self, from: data) {
            userCurrency = currency
            
        } else {
            userCurrency = .USD // Provide a default value
            print("No currencyDefault found, defaulting to USD")
        }
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
    
    // MARK: ADDITIONAL MISC. CALCULATIONS
    
    func bankrollByYear(year: String, sessionFilter: SessionFilter) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        
        var bankroll: Int {
            switch sessionFilter {
            case .all: sessions.filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
            case .cash: allCashSessions().filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
            case .tournaments: allTournamentSessions().filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
            }
        }

        return bankroll
    }
    
    // MARK: CHARTING FUNCTIONS
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
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
    func calculateCumulativeProfit(sessions: [PokerSession_v2], sessionFilter: SessionFilter) -> [Int] {
        
        /// We run this so that we can just use the Index as our X Axis value. Keeps spacing uniform and neat looking on the chart
        /// Then, in chart configuration, we just plot along the Index value, and Int is our cumulative profit amount
        var cumulativeProfit = 0
        
        // Take the cash / tournament filter and assign to this variable
        var filteredSessions: [PokerSession_v2] {
            switch sessionFilter {
            case .all: return sessions
            case .cash: return sessions.filter({ $0.isTournament == false })
            case .tournaments: return sessions.filter({ $0.isTournament == true })
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
    
    func sessionsByMonth(_ month: String) -> [PokerSession_v2] {
        sessions.filter({ $0.date.monthOfYear(month: $0.date) == month })
    }
    
    func profitByMonth(_ month: String) -> Int {
        return sessionsByMonth(month).reduce(0) { $0 + $1.profit }
    }
    
    func sessionsByStakes(_ stakes: String) -> [PokerSession_v2] {
        sessions.filter({ $0.stakes == stakes })
    }
    
    // Take in the stakes, and feed it which sessions to filter from
    func profitByStakes(stakes: String, sessions: [PokerSession_v2]) -> Int {
        return sessions.filter({ $0.stakes == stakes }).reduce(0) { $0 + $1.profit }
    }
    
    // Adds a new Session to var sessions, only used in AddNewSessionView and EditSession
    func addSession(_ session: PokerSession_v2, to bankrollID: UUID) {
        guard let index = bankrolls.firstIndex(where: { $0.id == bankrollID }) else { return }
        
        bankrolls[index].sessions.append(session)
        bankrolls[index].sessions.sort(by: { $0.date > $1.date })
    }
    
    // MARK: DELETE THIS
    func addNewSession(
        location: LocationModel_v2,
        date: Date,
        startTime: Date,
        endTime: Date,
        game: String,
        stakes: String,
        buyIn: Int,
        cashOut: Int,
        profit: Int,
        expenses: Int,
        notes: String,
        tags: [String],
        highHandBonus: Int,
        handsPerHour: Int,
        isTournament: Bool,
        rebuyCount: Int?,
        bounties: Int?,
        tournamentSize: String?,
        tournamentSpeed: String?,
        entrants: Int?,
        finish: Int?,
        tournamentDays: Int?,
        startTimeDayTwo: Date?,
        endTimeDayTwo: Date?,
        stakers: [Staker]?
    ) {
        
        let newSession = PokerSession_v2(
            location: location,
            date: date,
            startTime: startTime,
            endTime: endTime,
            game: game,
            stakes: stakes,
            buyIn: buyIn,
            cashOut: cashOut,
            profit: profit,
            expenses: expenses,
            notes: notes,
            tags: tags,
            highHandBonus: highHandBonus,
            handsPerHour: handsPerHour,
            isTournament: isTournament,
            rebuyCount: rebuyCount,
            bounties: bounties,
            tournamentSize: tournamentSize,
            tournamentSpeed: tournamentSpeed,
            entrants: entrants,
            finish: finish,
            tournamentDays: tournamentDays,
            startTimeDayTwo: startTimeDayTwo,
            endTimeDayTwo: endTimeDayTwo,
            stakers: stakers
        )
        
        sessions.append(newSession)
        sessions.sort(by: { $0.date > $1.date })
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
    
    /// Another potential crash point
    /// Added a safety check if the UserDefaults for the AppGroup fails
    func writeToWidget() {
        
        guard let defaults = UserDefaults(suiteName: AppGroup.bankrollSuite) else {
            print("Error: App Group UserDefaults not found.")
            return
        }
        
        self.convertToLineChartData()

        defaults.set(self.tallyBankroll(bankroll: .all), forKey: AppGroup.bankrollKey)
        defaults.set(self.sessions.first?.profit ?? 0, forKey: AppGroup.lastSessionKey)
        defaults.set(self.hourlyRate(bankroll: .all), forKey: AppGroup.hourlyKey)
        defaults.set(self.sessions.count, forKey: AppGroup.totalSessionsKey)
        defaults.set(self.userCurrency.rawValue, forKey: AppGroup.currencyKey)
        
        if let swiftChartData = try? JSONEncoder().encode(self.convertedLineChartData) {
            defaults.set(swiftChartData, forKey: AppGroup.swiftChartKey)
            
        } else {
            print("Error writing chart data.")
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: COUNT USER ACTIVITY FOR PAYWALL LOGIC
    
    func sessionsLoggedThisMonth(_ sessions: [PokerSession_v2]) -> Int {
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
        let loggedThisMonth = sessionsLoggedThisMonth(sessions)
        return loggedThisMonth < 3
    }
}

extension SessionsListViewModel {
    
    func allTournamentSessions() -> [PokerSession_v2] {
        return sessions.filter({ $0.isTournament == true })
    }
    
    func allCashSessions() -> [PokerSession_v2] {
        return sessions.filter({ $0.isTournament == false })
    }
}
