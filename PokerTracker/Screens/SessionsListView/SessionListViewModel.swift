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
    @Published var stakesProgress: Float = 0.0
    @Published var locations: [LocationModel] = DefaultLocations.allLocations
    {
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
        }
    }
    
    init() {
        getSessions()
        getLocations()
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
    
    // MARK: LOCATION FUNCTIONS SUCH AS ADD, DELETE, & MERGE
    
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
    
    // Will merge Default Locations in to the current saved Locations and also keep the same order
    // Question is, do we absolutely need to run this? If a user deletes a default location, they presumably don't want it back?
    // Maybe there's a "Restore to Defaults" button?
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
    
    // This is only working when you filter by .name versus the .id not sure why? Does it matter? What if the name is changed by the user?
    func uniqueLocationCount(location: LocationModel) -> Int {
        let array = self.sessions.filter({ $0.location.id == location.id })
        return array.count
    }
    
    func setUniqueStakes() {
        let sortedSessions = sessions.filter({ $0.isTournament == false || $0.isTournament == nil }).sorted(by: { $0.date > $1.date })
        uniqueStakes = Array(Set(sortedSessions.map({ $0.stakes })))
    }
    
    // MARK: FUNCTIONS FOR CIRCLE PROGRESS INDICATOR IN METRICS VIEW
    
    // Calculates target bankroll size given what size stakes were last played by the user
    func calculateTargetBankrollSize(from pokerSessions: [PokerSession]) -> Int? {
        guard let lastStake = pokerSessions.filter({ $0.isTournament == false || $0.isTournament == nil }).sorted(by: { $0.date > $1.date }).map({ $0.stakes }).first,
              let lastSlashIndex = lastStake.lastIndex(of: "/"),
              let bigBlind = Int(lastStake[lastSlashIndex...].trimmingCharacters(in: .punctuationCharacters)) else {
            
            return nil
        }

        // You want to have 60 buy-in's of your current stakes before advancing. 1 buy-in equals 100 big blinds. So, 100 x 60 = 6000 as our simple multiplier
        return bigBlind * 6000
    }
    
    // Called when Sessions is updated, will update the progress status for the stakes progress indicator
    func updateStakesProgress() {
        
        guard let targetBankroll = calculateTargetBankrollSize(from: sessions) else {
            return
        }
        
        self.stakesProgress = Float(tallyBankroll(bankroll: .all)) / Float(targetBankroll)
    }
    
    // MARK: CALCULATIONS & DATA PRESENTATION FOR CHARTS & METRICS VIEW
    
    // Calculate current bankroll
    func tallyBankroll(bankroll: SessionFilter) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        switch bankroll {
        case .all:
            return sessions.map { Int($0.profit) }.reduce(0, +)
        case .cash:
            return sessions.filter({ $0.isTournament == false }).map { Int($0.profit) }.reduce(0, +)
        case .tournaments:
            return sessions.filter({ $0.isTournament == true }).map { Int($0.profit) }.reduce(0, +)
        }
    }
    
    // Creates an array of our running, cumulative bankroll for use with charts
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
        
        var fewSessions = [Double]()
        var manySessions = [Double]()
        
        for (index, item) in chartArray().enumerated() {
            
            if index.isMultiple(of: 2) {
                fewSessions.append(item)
            }
        }
        
        for (index, item) in chartArray().enumerated() {
            
            if index.isMultiple(of: 5) {
                manySessions.append(item)
            }
        }
        
        // If there's over 25 sessions, we will use every other data point to build the chart.
        // If there's over 50 sessions, we count by 5's in order to smooth out the chart and make it appear less erratic
        if chartArray().count > 50 {
            return manySessions.enumerated().map({ Point(x:CGFloat($0.offset), y: $0.element) })
            
        } else if chartArray().count > 25 {
            return fewSessions.enumerated().map({ Point(x:CGFloat($0.offset), y: $0.element) })
        }
        
        else {
            return chartArray().enumerated().map({ Point(x:CGFloat($0.offset), y: $0.element) })
        }
    }
    
    // Simply counts how many sessions played each year
    func sessionsPerYear(year: String) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.filter({ $0.date.getYear() == year }).count
    }
    
    // Adds up total number of profitable cash sessions
    func numOfCashes() -> Int {
        guard !sessions.filter({ $0.isTournament == false }).isEmpty else { return 0 }
        
        let sessionsArray = sessions.filter({ $0.isTournament == false })
        return sessionsArray.filter { $0.profit > 0 }.count
    }
    
    // Returns percentage of winning seessions
    func winRate() -> String {
        guard !sessions.filter({ $0.isTournament == false }).isEmpty else { return "0%" }
        let cashSessions = sessions.filter({ $0.isTournament == false })
        let winPercentage = Double(numOfCashes()) / Double(cashSessions.count)
        return winPercentage.asPercent()
    }
    
    func totalWinRate() -> String {
        guard !sessions.isEmpty else { return "0%" }
        let profitableSessions = sessions.filter({ $0.profit > 0 }).count
        let winPercentage = Double(profitableSessions) / Double(sessions.count)
        return winPercentage.asPercent()
    }
    
    // Standard deviation function on a per session basis
    func standardDeviation() -> Int {
        
        guard sessions.count > 1 else {
            // Not enough data points to calculate standard deviation
            return 0
        }

        let profitArray = sessions.map { $0.profit }
        let mean = profitArray.reduce(0, +) / profitArray.count
        let variance = profitArray.reduce(0) { (result, profit) in
            result + pow(Double(profit - mean), 2)
        } / Double(profitArray.count - 1)

        return Int(sqrt(variance))
    }
    
    // Calculate total hourly earnings rate for MetricsView
    func hourlyRate(bankroll: SessionFilter) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        switch bankroll {
        case .all:
            let totalHours = sessions.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
            let totalMinutes = Float(sessions.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
            if totalHours < 1 {
                return Int(Float(tallyBankroll(bankroll: .all)) / (totalMinutes / 60))
            } else {
                return tallyBankroll(bankroll: .all) / totalHours
            }
        case .cash:
            guard !sessions.filter({ $0.isTournament == false }).isEmpty else { return 0 }
            let totalHours = sessions.filter({ $0.isTournament == false }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
            let totalMinutes = Float(sessions.filter({ $0.isTournament == false }).map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
            if totalHours < 1 {
                return Int(Float(tallyBankroll(bankroll: bankroll)) / (totalMinutes / 60))
            } else {
                return tallyBankroll(bankroll: bankroll) / totalHours
            }
        case .tournaments:
            guard !sessions.filter({ $0.isTournament == true }).isEmpty else { return 0 }
            let totalHours = sessions.filter({ $0.isTournament == true }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
            let totalMinutes = Float(sessions.filter({ $0.isTournament == true }).map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
            if totalHours < 1 {
                return Int(Float(tallyBankroll(bankroll: bankroll)) / (totalMinutes / 60))
            } else {
                return tallyBankroll(bankroll: bankroll) / totalHours
            }
        }
    }
    
    // Calculate average session duration for MetricsView
    func avgDuration(bankroll: SessionFilter) -> String {
        
        var sessionsArray: [PokerSession] {
            switch bankroll {
            case .all:
                return sessions
            case .cash:
                return sessions.filter({ $0.isTournament == false })
            case .tournaments:
                return sessions.filter({ $0.isTournament == true })
            }
        }
        
        guard !sessionsArray.isEmpty else { return "0" }
        
        let hoursArray: [Int] = sessionsArray.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessionsArray.map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +) / sessionsArray.count
        let totalMinutes = minutesArray.reduce(0, +) / sessionsArray.count
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.formattedDuration
    }
    
    // Calculate average profit per session
    func avgProfit(bankroll: SessionFilter) -> Int {
        switch bankroll {
        case .all:
            guard !sessions.isEmpty else { return 0 }
            return tallyBankroll(bankroll: bankroll) / sessions.count
        case .cash:
            guard !sessions.filter({ $0.isTournament == false }).isEmpty else { return 0 }
            return tallyBankroll(bankroll: bankroll) / sessions.filter({ $0.isTournament == false }).count
        case .tournaments:
            guard !sessions.filter({ $0.isTournament == true }).isEmpty else { return 0 }
            return tallyBankroll(bankroll: bankroll) / sessions.filter({ $0.isTournament == true }).count
        }
    }
    
    // Calculate average cost of Tournament buy in's
    func avgTournamentBuyIn() -> Int {
        guard !sessions.isEmpty else { return 0 }
        guard sessions.contains(where: { $0.isTournament == true }) else {
            return 0
        }
        
        let tournamentBuyIns = sessions.filter { $0.isTournament == true }.map { $0.expenses ?? 0 }.reduce(0, +)
        let count = sessions.filter { $0.isTournament == true }.count
        
        return tournamentBuyIns / count
    }
    
    // Total hours played from all sessions
    func totalHoursPlayed(bankroll: SessionFilter) -> String {
        
        var sessionsArray: [PokerSession] {
            switch bankroll {
            case .all:
                return sessions
            case .cash:
                return sessions.filter({ $0.isTournament == false })
            case .tournaments:
                return sessions.filter({ $0.isTournament == true })
            }
        }
        
        guard !sessionsArray.isEmpty else { return "0" }
        let totalHours = sessionsArray.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMins = sessionsArray.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMins)
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    // User's longest win streak
    func winStreak() -> Int {
        var consecutiveCount = 0
        var maxConsecutiveCount = 0

        for session in sessions {
            if session.profit > 0 {
                consecutiveCount += 1
                maxConsecutiveCount = max(maxConsecutiveCount, consecutiveCount)
            } else {
                consecutiveCount = 0
            }
        }

        return maxConsecutiveCount
    }
    
    // Formatted specifically for home screen dashboard
    func totalHoursPlayedHomeScreen() -> String {
        guard !sessions.isEmpty else { return "0" }
        let totalHours = sessions.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMins = sessions.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMins)
        return String(Int(dateComponents.durationInHours).abbreviateHourTotal)
    }
    
    // Tournament ITM Ratio
    func inTheMoneyRatio() -> String {
        guard !sessions.filter({ $0.isTournament == true }).isEmpty else { return "0%" }
        let tournamentWins = sessions.filter({ $0.isTournament == true && $0.profit > 0 }).count
        let totalTournaments = sessions.filter({ $0.isTournament == true }).count
        let winRatio = Double(tournamentWins) / Double(totalTournaments)
        return winRatio.asPercent()
    }
    
    func tournamentReturnOnInvestment() -> String {
        guard !sessions.filter({ $0.isTournament == true }).isEmpty else { return "0%" }
        
        // It's Ok to force unwrap expenses because all tournaments MUST have an expense entered
        let totalBuyIns = sessions.filter({ $0.isTournament == true }).map({ $0.expenses! }).reduce(0,+)
        
        // Need total tournament winnings. Adding expenses back here because we need gross winnings, not net winnings
        let totalWinnings = sessions.filter({ $0.isTournament == true }).map({ $0.profit + $0.expenses! }).reduce(0,+)
        
        // ROI = Total winnings - Total buy ins / total buy ins
        let returnOnInvestment = (Double(totalWinnings) - Double(totalBuyIns)) / Double(totalBuyIns)
        
        return returnOnInvestment.asPercent()
    }
    
    // MARK: CALCULATIONS FOR ANNUAL REPORT VIEW
    
    func allSessionDataByYear(year: String) -> [PokerSession] {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return [] }
        return sessions.filter({ $0.date.getYear() == year })
    }
    
    func grossIncome() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let netProfit = sessions.map { Int($0.profit) }.reduce(0, +)
        let totalExpenses = sessions.map { Int($0.expenses ?? 0) }.reduce(0, +)
        let grossIncome = netProfit + totalExpenses
        return grossIncome
    }
    
    func grossIncomeByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let netProfit = sessions.filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
        let totalExpenses = sessions.filter({ $0.date.getYear() == year }).map { Int($0.expenses ?? 0) }.reduce(0, +)
        let grossIncome = netProfit + totalExpenses
        return grossIncome
    }
    
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
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return "0%" }
        let wins = Double(numOfCashesByYear(year: year))
        let sessions = Double(sessionsPerYear(year: year))
        let winPercentage = wins / sessions
        return winPercentage.asPercent()
    }
    
    func bestLocation(year: String? = nil) -> LocationModel? {
        guard !sessions.isEmpty else { return DefaultData.defaultLocation }
        if let yearFilter = year {
            let filteredSessions = sessions.filter({ $0.date.getYear() == yearFilter }).map({ ($0.location, $0.profit) })
            let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
            return maxProfit?.key
            
        } else {
            let locationTuple = sessions.map({ ($0.location, $0.profit) })
            let maxProfit = Dictionary(locationTuple, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
            return maxProfit?.key
        }   
    }
    
    func bestSession(year: String? = nil) -> Int? {
        guard !sessions.isEmpty else { return 0 }
        if let yearFilter = year {
            let filteredSessions = sessions.filter({ $0.date.getYear() == yearFilter })
            return filteredSessions.map({ $0.profit }).max(by: { $0 < $1 })
        }
        
        else {
            let bestSession = sessions.map({ $0.profit }).max(by: { $0 < $1 })
            return bestSession
        }
    }
    
    // MARK: CHARTING FUNCTIONS
    
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
    
    // Used in ToolTipView for Bar Chart in Metrics View
    func mostProfitableMonth(in sessions: [PokerSession]) -> String {
        
        // Create a dictionary to store total profit for each month
        var monthlyProfits: [Int: Int] = [:]
        
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Iterate through sessions and accumulate profit for each month
        for session in sessions {
            
            let yearOfSession = Calendar.current.component(.year, from: session.date)
            
            // Check if the session is from the current year
            if yearOfSession == currentYear {
                let month = Calendar.current.component(.month, from: session.date)
                monthlyProfits[month, default: 0] += session.profit
            }
        }
        
        // Find the month with the highest profit
        if let mostProfitableMonth = monthlyProfits.max(by: { $0.value < $1.value }) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            let monthString = monthFormatter.monthSymbols[mostProfitableMonth.key - 1]
            
            return monthString
            
        } else {
            return "Undetermined"
        }
    }
    
    var bestMonth: String {
        
        mostProfitableMonth(in: sessions)
        
    }
    
    // MARK: ADDITIONAL METRICS CARDS
    
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
                    entrants: Int) {
        
        let newSession = PokerSession(location: location,
                                      game: game,
                                      stakes: stakes,
                                      date: date,
                                      profit: profit,
                                      notes: notes,
                                      startTime: startTime, endTime: endTime,
                                      expenses: expenses,
                                      isTournament: isTournament,
                                      entrants: entrants)
        sessions.append(newSession)
        sessions.sort(by: {$0.date > $1.date})
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

        guard let chartData = try? JSONEncoder().encode(self.chartCoordinates()) else {
            print("Error writing chart data")
            return
        }

        defaults.set(chartData, forKey: AppGroup.chartKey)
        WidgetCenter.shared.reloadAllTimelines()
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
    
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let daysOfWeekAbbreviated = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}
