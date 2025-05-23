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
    @Published var progressRingTrigger = UUID()
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
    @Published private(set) var filteredSessions: [PokerSession_v2] = []
    @Published private(set) var bankrollLineChartData: [Int] = [0]
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
            writeToWidget()
        }
    }
    
    @AppStorage("userRiskTolerance") var riskRaw: String = UserRiskTolerance.conservative.rawValue
    @AppStorage("multipleBankrollsEnabled") var multipleBankrollsEnabled: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fileAccessAvailable), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        if multipleBankrollsEnabled {
            loadBankrolls()
        }
        getNewSessions()
        getNewLocations()
        getTransactions()
        getUserStakes()
        getUserCurrency()
        getUserGameTypes()
        writeToWidget()
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
            alertMessage = error.localizedDescription
        }
    }
    
    func getUserGameTypes() {
        let defaultGameTypes = ["NL Texas Hold Em", "Pot Limit Omaha", "Seven Card Stud", "Razz", "Mixed"]
        
        do {
            let data = try Data(contentsOf: gameTypePath)
            let importedGameTypes = try JSONDecoder().decode([String].self, from: data)
            
            let combined = (defaultGameTypes + importedGameTypes).uniqued()
            self.userGameTypes = combined
            
        } catch {
            print("Failed to load user game types with error: \(error)")
            alertMessage = error.localizedDescription
            self.userGameTypes = defaultGameTypes
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
    
    /// Helper function to filter Sessions based on a BankrollSelection filter
    func sessions(for selection: BankrollSelection) -> [PokerSession_v2] {
        switch selection {
        case .all: return sessions + bankrolls.flatMap(\.sessions)
        case .default: return sessions
        case .custom(let id): return bankrolls.first(where: { $0.id == id })?.sessions ?? []
        }
    }
    
    // MARK: CALCULATIONS & DATA PRESENTATION FOR CHARTS & METRICS VIEW
    
    // Simply counts how many sessions played each year
    func sessionsPerYear(year: String) -> Int {
        guard !allSessions.isEmpty else { return 0 }
        return allSessions.filter({ $0.date.getYear() == year }).count
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
        guard !allSessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        
        var bankroll: Int {
            switch sessionFilter {
            case .all: allSessions.filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
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
            let newDataPoints = calculateCumulativeProfit(sessions: allSessions, sessionFilter: .all)
            originalDataPoint += newDataPoints
            return originalDataPoint
        }
        
        self.convertedLineChartData = convertedData
    }
    
    func refreshFiltered(bankroll: BankrollSelection, range: RangeSelection, session: SessionFilter) {
        // Build your “all sessions” one time
        let all: [PokerSession_v2] = {
            switch bankroll {
            case .all:return sessions + bankrolls.flatMap(\.sessions)
            case .default:return sessions
            case .custom(let id):return bankrolls.first(where: { $0.id == id })?.sessions ?? []
            }
        }()
        
        // Compute your date‐cutoff constants once
        let now = Date()
        let cal = Calendar.current
        let oneMonth = cal.date(byAdding: .month, value: -1, to: now)!
        let threeMo = cal.date(byAdding: .month, value: -3, to: now)!
        let sixMo = cal.date(byAdding: .month, value: -6, to: now)!
        let oneYr = cal.date(byAdding: .year,  value: -1, to: now)!
        let ytdStart = cal.date(from: cal.dateComponents([.year], from: now))!
        
        // Run your date‐filter exactly once
        let byDate: [PokerSession_v2] = {
            switch range {
            case .all: return all
            case .oneMonth:  return all.filter { $0.date >= oneMonth }
            case .threeMonth: return all.filter { $0.date >= threeMo }
            case .sixMonth: return all.filter { $0.date >= sixMo }
            case .oneYear: return all.filter { $0.date >= oneYr }
            case .ytd: return all.filter { $0.date >= ytdStart }
            }
        }()
        
        // Split cash vs. tournaments exactly once
        let computedArray: [PokerSession_v2] = {
            switch session {
            case .all: return byDate
            case .cash: return byDate.filter { !$0.isTournament }
            case .tournaments: return byDate.filter { $0.isTournament }
            }
        }()
        
        // Assign your filtered sessions
        self.filteredSessions = computedArray
        
        // Turn those sessions into your `[Int]` for the chart, once
        let profits = calculateCumulativeProfit(sessions: computedArray, sessionFilter: session)
        self.bankrollLineChartData = [0] + profits
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
    
    func sessionsByStakes(_ stakes: String) -> [PokerSession_v2] {
        allSessions.filter({ $0.stakes == stakes })
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
    
    func removeSession(_ session: PokerSession_v2, from bankrollID: UUID) {
        guard let index = bankrolls.firstIndex(where: { $0.id == bankrollID }) else { return }
        bankrolls[index].sessions.removeAll(where: { $0.id == session.id })
    }
    
    func createTransaction(date: Date, type: TransactionType, amount: Int, notes: String, tags: [String]?) -> BankrollTransaction {
        let signedAmount = (type == .withdrawal || type == .expense) ? -amount : amount
        return BankrollTransaction(date: date, type: type, amount: signedAmount, notes: notes, tags: tags)
    }
    
    func addTransaction(_ transaction: BankrollTransaction, to bankrollID: UUID) {
        guard let index = bankrolls.firstIndex(where: { $0.id == bankrollID }) else { return }
        bankrolls[index].transactions.append(transaction)
        bankrolls[index].transactions.sort(by: { $0.date > $1.date })
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

        defaults.set(self.tallyBankroll(bankroll: .all, type: .all, range: .all), forKey: AppGroup.bankrollKey)
        defaults.set(self.allSessions.first?.profit ?? 0, forKey: AppGroup.lastSessionKey)
        defaults.set(self.hourlyRate(bankroll: .all, type: .all, range: .all), forKey: AppGroup.hourlyKey)
        defaults.set(self.allSessions.count, forKey: AppGroup.totalSessionsKey)
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
        let loggedThisMonth = sessionsLoggedThisMonth(allSessions)
        return loggedThisMonth < 3
    }
}

extension SessionsListViewModel {
    
    // Combining original session data, aka "Default Bankroll" and any newly created bankroll sessions
    var allSessions: [PokerSession_v2] {
        (sessions + bankrolls.flatMap(\.sessions)).sorted(by: { $0.date > $1.date })
    }
    
    var allTransactions: [BankrollTransaction] {
        transactions + bankrolls.flatMap({ $0.transactions }).sorted(by: { $0.date > $1.date })
    }
    
    func allTournamentSessions() -> [PokerSession_v2] {
        return allSessions.filter({ $0.isTournament == true })
    }
    
    func allCashSessions() -> [PokerSession_v2] {
        return allSessions.filter({ $0.isTournament == false })
    }
}
