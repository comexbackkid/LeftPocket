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
    @Published var finish: String = ""
    @Published var size: String = ""
    @Published var speed: String = ""
    @Published var tags: String = ""
    @Published var staking: Bool = false
    @Published var actionSold: String = ""
    @Published var stakerName: String = ""
    @Published var stakerList: [Staker] = []
    @Published var multiDayToggle: Bool = false
    @Published var addDay: Bool = false
    @Published var noMoreDays: Bool = false
    
    // Making sure to include rebuys in profit calculation
    var computedProfit: Int {
        if sessionType == .cash {
            return (Int(cashOut) ?? 0) - (Int(buyIn) ?? 0) - (Int(cashRebuys) ?? 0)
        } else {
            return (Int(cashOut) ?? 0) - (Int(buyIn) ?? 0) - tournamentRebuys - totalActionSold
        }
    }
    
    // How many days was the Tournament, default to 1
    var computedNumberOfTournamentDays: Int {
        if multiDayToggle == true {
            return 2
        } else {
            return 1
        }
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
            let amountOwed = (Double(cashOut) ?? 0) * totalPercentage
            return Int(amountOwed)
        } else {
            return 0
        }
    }

    // Add name & action amount to the array of [Staker]
    func addStaker(_ name: String, _ action: Double) {
        guard !stakerName.isEmpty, action > 0 else { return }
        let newStaker = Staker(name: name, percentage: (action / 100))
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
            } else if multiDayToggle && (!addDay || !noMoreDays) {
                error = AlertContext.invalidTournamentDates
            } else if multiDayToggle && (endTimeDayTwo <= startTimeDayTwo) {
                error = AlertContext.invalidEndTime
            } else if multiDayToggle && (startTimeDayTwo <= endTime) {
                error = AlertContext.invalidDayTwoStartTime
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
                                isTournament: sessionType == .tournament ? true : false,
                                rebuyCount: Int(rebuyCount) ?? nil,
                                tournamentSize: !size.isEmpty ? size : nil,
                                tournamentSpeed: !speed.isEmpty ? speed : nil,
                                entrants: Int(entrants),
                                finish: Int(finish),
                                tournamentDays: sessionType == .tournament ? computedNumberOfTournamentDays : nil,
                                startTimeDayTwo: computedNumberOfTournamentDays > 1 ? startTimeDayTwo : nil,
                                endTimeDayTwo: computedNumberOfTournamentDays > 1 ? endTimeDayTwo : nil,
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
