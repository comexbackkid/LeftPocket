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
    
    @Published var location: LocationModel = LocationModel(name: "", localImage: "", imageURL: "")
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
    @Published var multiDayToggle: Bool = false
    @Published var addDay: Bool = false
    @Published var noMoreDays: Bool = false
    
    // Just using this value for Cash games
    var computedProfit: Int {
        (Int(cashOut) ?? 0) - Int(buyIn)! - (Int(cashRebuys) ?? 0)
    }
    
    // How many days was the Tournamnet
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
        if let encodedLocation = defaults.object(forKey: "locationDefault") as? Data, let decodedLocation = try? JSONDecoder().decode(LocationModel.self, from: encodedLocation) {
            location = decodedLocation
        } else {
            location = LocationModel(name: "", localImage: "", imageURL: "")
        }
        
        // Load Stakes, Game, & Tournament Defaults
        stakes = defaults.string(forKey: "stakesDefault") ?? ""
        game = defaults.string(forKey: "gameDefault") ?? ""
        size = defaults.string(forKey: "tournamentSizeDefault") ?? ""
        speed = defaults.string(forKey: "tournamentSpeedDefault") ?? ""
    }
    
    func savedButtonPressed(viewModel: SessionsListViewModel) {
        
        guard self.validateForm() else { return }
        viewModel.addSession(location: self.location,
                             game: self.game,
                             stakes: self.stakes,
                             date: self.startTime,
                             profit: sessionType == .cash ? computedProfit - (Int(self.expenses) ?? 0) : (Int(self.cashOut) ?? 0) - (Int(self.buyIn) ?? 0) - self.tournamentRebuys,
                             notes: self.notes,
                             startTime: self.startTime,
                             endTime: self.endTime,
                             // Tournament metrics in the app look to 'expenses' for Buy In data.
                             expenses: sessionType == .cash ? Int(self.expenses) ?? 0 : (Int(buyIn) ?? 0) + self.tournamentRebuys,
                             isTournament: sessionType == .tournament,
                             entrants: Int(self.entrants) ?? 0,
                             finish: Int(self.finish) ?? 0,
                             highHandBonus: Int(self.highHandBonus) ?? 0,
                             buyIn: (Int(self.buyIn) ?? 0) + (sessionType == .cash ? (Int(self.cashRebuys) ?? 0) : 0),
                             cashOut: Int(self.cashOut) ?? 0,
                             rebuyCount: Int(self.rebuyCount) ?? 0,
                             tournamentSize: self.size,
                             tournamentSpeed: self.speed,
                             tags: self.tags.isEmpty ? nil : [self.tags],
                             // Calculate if this is a Multi-Day Tournament. If so, provide the properties with values, otherwise just record nil
                             tournamentDays: computedNumberOfTournamentDays,
                             startTimeDayTwo: computedNumberOfTournamentDays > 1 ? self.startTimeDayTwo : nil,
                             endTimeDayTwo: computedNumberOfTournamentDays > 1 ? self.endTimeDayTwo : nil)
        
        Task {
            // Counting how many times the user adds a Session. Will display Tip after they enter two
            if #available(iOS 17.0, *) {
                await FilterSessionsTip.sessionCount.donate()
            }
        }
        
        // Only after the form checks out will the presentation be set to false and the sheet will dismiss
        self.presentation = false
    }
}

enum SessionType: String, Codable { case cash, tournament }
