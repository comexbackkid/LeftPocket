//
//  NewSessionViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/27/21.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import TipKit

final class NewSessionViewModel: ObservableObject {
    
    @Published var location: LocationModel_v2 = LocationModel_v2(name: "")
    @Published var game: String = ""
    @Published var stakes: String = ""
    @Published var profit: String = ""
    @Published var positiveNegative: String = "+"
    @Published var notes: String = ""
    @Published var startTime: Date = Date().modifyTime(minutes: -300)
    @Published var endTime: Date = Date()
    @Published var startTimeDayTwo: Date = Date()
    @Published var endTimeDayTwo: Date = Date()
    @Published var startTimeDayThree: Date = Date()
    @Published var endTimeDayThree: Date = Date()
    @Published var startTimeDayFour: Date = Date()
    @Published var endTimeDayFour: Date = Date()
    @Published var startTimeDayFive: Date = Date()
    @Published var endTimeDayFive: Date = Date()
    @Published var startTimeDaySix: Date = Date()
    @Published var endTimeDaySix: Date = Date()
    @Published var startTimeDaySeven: Date = Date()
    @Published var endTimeDaySeven: Date = Date()
    @Published var startTimeDayEight: Date = Date()
    @Published var endTimeDayEight: Date = Date()
    @Published var expenses: String = ""
    @Published var presentation: Bool?
    @Published var sessionType: SessionType?
    @Published var entrants: String = ""
    @Published var alertItem: AlertItem?
    @Published var buyIn: String = ""
    @Published var cashOut: String = ""
    @Published var highHandBonus: String = ""
    @Published var rebuyCount: String = ""
    @Published var cashRebuys: String = ""
    @Published var bounties: String = ""
    @Published var finish: String = ""
    @Published var size: String = ""
    @Published var speed: String = ""
    @Published var tags: String = ""
    @Published var staking: Bool = false
    @Published var handsPerHour: Int = 25
    @Published var actionSold: String = ""
    @Published var stakerName: String = ""
    @Published var stakerList: [Staker] = []
    @Published var markup: Double = 1.0
    @Published var showHandsPerHour: Bool = false
    @Published var hasBounties: Bool = false
    @Published var multiDayToggle: Bool = false
    @Published var addDay: Bool = false
    @Published var tournamentDays: Int = 1
    @Published var noMoreDays: Bool = false
    
    // Making sure to include rebuys in profit calculation
    var computedProfit: Int {
        if sessionType == .cash {
            return (Int(cashOut) ?? 0) - (Int(buyIn) ?? 0) - (Int(cashRebuys) ?? 0)
            
        } else {
            let tournamentWinnings = (Int(cashOut) ?? 0) + (Int(bounties) ?? 0)
            
            // Calculate total staker percentage
            let totalPercentageSold = stakerList.reduce(0.0) { $0 + $1.percentage }
            
            // Corrected Player Buy-in Cost (subtract stakers' share of both buy-in and rebuys)
            let totalBuyIn = (Int(buyIn) ?? 0) + tournamentRebuys
            let stakersContribution = Double(totalBuyIn) * totalPercentageSold
            let playerBuyInCost = totalBuyIn - Int(stakersContribution)
            
            // Compute the total action sold (based on winnings split, NOT buy-in)
            let totalActionSold = stakerList.reduce(0.0) { total, staker in
                return total + (Double(tournamentWinnings) * staker.percentage)
            }
            
            // Compute the markup earned (extra money from backers)
            let markupEarned = stakerList.reduce(0.0) { total, staker in
                let stakeCostWithoutMarkup = (Double(buyIn) ?? 0) * staker.percentage
                let markupAmount = stakeCostWithoutMarkup * ((staker.markup ?? 1.0) - 1.0)
                return total + markupAmount
            }
            
            return tournamentWinnings - playerBuyInCost + Int(markupEarned) - Int(totalActionSold)
        }
    }
    
    // Adjusted Start/End Time for Day Two, default to day two's start time if it's only a two-day tournament
    var adjustedStartTimeDayTwo: Date? {
        guard self.tournamentDays > 2 else { return startTimeDayTwo }
        return startTimeDayTwo
    }
    
    // If tournamentDays are greater than two, we'll compute an arbitrary end time for endTimeDayTwo to get an accurate time duration
    var adjustedEndTimeDayTwo: Date? {
        guard self.tournamentDays > 2, let startTimeDayTwo = adjustedStartTimeDayTwo else { return endTimeDayTwo }
        let totalHoursPlayed = calculateTotalPlayTimeFromMultiDayTournament()
        return startTimeDayTwo.addingTimeInterval(TimeInterval(totalHoursPlayed * 3600))
    }
    
    // Computes total duration of all played sessions in hours
    private func calculateTotalPlayTimeFromMultiDayTournament() -> Int {
        let dayDurations = [
            Calendar.current.dateComponents([.hour], from: startTimeDayTwo, to: endTimeDayTwo).hour ?? 0,
            Calendar.current.dateComponents([.hour], from: startTimeDayThree, to: endTimeDayThree).hour ?? 0,
            Calendar.current.dateComponents([.hour], from: startTimeDayFour, to: endTimeDayFour).hour ?? 0,
            Calendar.current.dateComponents([.hour], from: startTimeDayFive, to: endTimeDayFive).hour ?? 0,
            Calendar.current.dateComponents([.hour], from: startTimeDaySix, to: endTimeDaySix).hour ?? 0,
            Calendar.current.dateComponents([.hour], from: startTimeDaySeven, to: endTimeDaySeven).hour ?? 0,
            Calendar.current.dateComponents([.hour], from: startTimeDayEight, to: endTimeDayEight).hour ?? 0
        ]
 
        // Sum only the relevant days based on tournamentDays
        return dayDurations.prefix(tournamentDays).reduce(0, +)
    }
    
    // Adds up the total dollar amount of Tournament rebuys
    var tournamentRebuys: Int {
        guard !rebuyCount.isEmpty else { return 0 }
        
        let buyIn = Int(self.buyIn) ?? 0
        let numberOfRebuys = Int(rebuyCount) ?? 0
        
        return buyIn * numberOfRebuys
    }
    
    // If Tournament action was sold, calculate how much is owed to them if we won
    var totalActionSold: Int {
        if sessionType == .tournament {
            let totalPercentage = stakerList.reduce(0) { $0 + $1.percentage }
            let totalWinnings = (Double(cashOut) ?? 0) + (Double(bounties) ?? 0)
            let amountOwed = totalWinnings * totalPercentage
            return Int(amountOwed)
        } else {
            return 0
        }
    }

    // Add name & action amount to the array of [Staker]
    func addStaker(_ name: String, _ action: Double) {
        guard !stakerName.isEmpty, action > 0 else { return }
        let newStaker = Staker(name: name, percentage: (action / 100), markup: self.markup)
        stakerList.append(newStaker)
    }
    
    // Remove selected name from array of [Staker]
    func removeStaker(_ staker: Staker) {
        stakerList.removeAll { $0.id == staker.id }
    }
    
    // Testing new form validation method
    func validateForm() -> Bool {
        var error: AlertItem? = nil

        if sessionType == nil {
            error = AlertContext.invalidSession
        } else if location.name.isEmpty {
            error = AlertContext.inValidLocation
        } else if sessionType == .cash {
            if stakes.isEmpty {
                error = AlertContext.inValidStakes
            } else if buyIn.isEmpty {
                error = AlertContext.invalidBuyIn
            }
        } else {
            if speed.isEmpty {
                error = AlertContext.invalidSpeed
            } else if size.isEmpty {
                error = AlertContext.invalidSize
            } else if entrants.isEmpty {
                error = AlertContext.invalidEntrants
            } else if finish.isEmpty {
                error = AlertContext.invalidFinish
            } else if Int(finish)! >= Int(entrants)! {
                error = AlertContext.invalidFinishPlace
            } else if buyIn.isEmpty {
                error = AlertContext.invalidBuyIn
            } else if multiDayToggle && (tournamentDays < 2 || !noMoreDays) {
                error = AlertContext.invalidTournamentDates
            } else if staking && stakerList.isEmpty {
                error = AlertContext.invalidStaking
            }
        }

        if game.isEmpty {
            error = AlertContext.inValidGame
        } else if endTime <= startTime {
            error = AlertContext.invalidEndTime
        } else if endTime.timeIntervalSince(startTime) <= 60 {
            error = AlertContext.invalidDuration
        }

        if let error = error {
            alertItem = error
            return false
        }

        return true
    }
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
        // Load Session Type
        if let encodedSessionType = defaults.object(forKey: "sessionTypeDefault") as? Data, let decodedSessionType = try? JSONDecoder().decode(SessionType.self, from: encodedSessionType) {
            sessionType = decodedSessionType
        } else {
            sessionType = nil
        }
        
        // Load Location
        if let encodedLocation = defaults.object(forKey: "locationDefault") as? Data, let decodedLocation = try? JSONDecoder().decode(LocationModel_v2.self, from: encodedLocation) {
            location = decodedLocation
        } else {
            location = LocationModel_v2(name: "")
        }
        
        // Load Stakes, Game, & Tournament Defaults
        stakes = defaults.string(forKey: "stakesDefault") ?? ""
        game = defaults.string(forKey: "gameDefault") ?? ""
        size = defaults.string(forKey: "tournamentSizeDefault") ?? ""
        speed = defaults.string(forKey: "tournamentSpeedDefault") ?? ""
        handsPerHour = defaults.integer(forKey: "handsPerHourDefault")
        showHandsPerHour = defaults.bool(forKey: "showHandsPerHourOnNewSessionView")
    }
    
    func savedButtonPressed(viewModel: SessionsListViewModel) {
        
        guard self.validateForm() else { return }
        viewModel.addNewSession(location: location,
                                date: startTime,
                                startTime: startTime,
                                endTime: endTime,
                                game: game,
                                stakes: stakes,
                                buyIn: (Int(buyIn) ?? 0) + (sessionType == .cash ? (Int(self.cashRebuys) ?? 0) : 0),
                                cashOut: Int(cashOut) ?? 0,
                                profit: computedProfit,
                                expenses: Int(expenses) ?? 0,
                                notes: notes,
                                tags: tags.isEmpty ? [] : [tags],
                                highHandBonus: Int(highHandBonus) ?? 0,
                                handsPerHour: handsPerHour,
                                isTournament: sessionType == .tournament ? true : false,
                                rebuyCount: Int(rebuyCount) ?? nil,
                                bounties: Int(bounties) ?? nil,
                                tournamentSize: !size.isEmpty ? size : nil,
                                tournamentSpeed: !speed.isEmpty ? speed : nil,
                                entrants: Int(entrants),
                                finish: Int(finish),
                                tournamentDays: sessionType == .tournament ? tournamentDays : nil,
                                startTimeDayTwo: tournamentDays > 1 ? adjustedStartTimeDayTwo : nil,
                                endTimeDayTwo: tournamentDays > 1 ? adjustedEndTimeDayTwo : nil,
                                stakers: sessionType == .tournament && !stakerList.isEmpty ? stakerList : nil)
        
        Task {
            // Counting how many times the user adds a Session. Will display Tip after they enter two
            await FilterSessionsTip.sessionCount.donate()
        }
        
        // Only after the form checks out will the presentation be set to false and the sheet will dismiss
        self.presentation = false
    }
}

enum SessionType: String, Codable { case cash, tournament }
