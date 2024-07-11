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
    
    enum SessionType: String, Codable { case cash, tournament }
    
    @Published var location: LocationModel = LocationModel(name: "", localImage: "", imageURL: "")
    @Published var game: String = ""
    @Published var stakes: String = ""
    @Published var profit: String = ""
    @Published var positiveNegative: String = "+"
    @Published var notes: String = ""
    @Published var startTime: Date = Date().modifyTime(minutes: -300)
    @Published var endTime: Date = Date()
    @Published var expenses: String = ""
    @Published var presentation: Bool?
    @Published var sessionType: SessionType?
    @Published var entrants: String = ""
    @Published var alertItem: AlertItem?
    @Published var buyIn: String = ""
    @Published var cashOut: String = ""
    @Published var highHandBonus: String = ""
    
    var computedProfit: Int {
        (Int(cashOut) ?? 0) - Int(buyIn)!
    }
    
    var isValidForm: Bool {
        
        guard sessionType != nil else {
            alertItem = AlertContext.invalidSession
            return false
        }
        
        guard !location.name.isEmpty else {
            alertItem = AlertContext.inValidLocation
            return false
        }
        
        // Run this check if it's a Cash game
        if sessionType == .cash {
            guard !stakes.isEmpty else {
                alertItem = AlertContext.inValidStakes
                return false
            }
            
            guard !buyIn.isEmpty else {
                alertItem = AlertContext.invalidBuyIn
                return false
            }
            
        } else {
            
            // Run this check for Tournaments
            guard !entrants.isEmpty else {
                alertItem = AlertContext.invalidEntrants
                return false
            }
            
            guard !buyIn.isEmpty else {
                alertItem = AlertContext.invalidBuyIn
                return false
            }
        }
        
        guard !game.isEmpty else {
            alertItem = AlertContext.inValidGame
            return false
        }
        
        guard endTime > startTime else {
            alertItem = AlertContext.invalidEndTime
            return false
        }
        
        guard endTime.timeIntervalSince(startTime) > 60 else {
            alertItem = AlertContext.invalidDuration
            return false
        }
 
        return true
    }
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
        guard
            let encodedSessionType = defaults.object(forKey: "sessionTypeDefault") as? Data,
            let decodedSessionType = try? JSONDecoder().decode(SessionType.self, from: encodedSessionType)
                
        else { return }
        
        sessionType = decodedSessionType
        
        guard
            let encodedLocation = defaults.object(forKey: "locationDefault") as? Data,
            let decodedLocation = try? JSONDecoder().decode(LocationModel.self, from: encodedLocation)
                
        else { return }
        
        location = decodedLocation
        
        guard
            let encodedStakes = defaults.string(forKey: "stakesDefault"),
            let encodedGame = defaults.string(forKey: "gameDefault")
                
        else { return }
        
        stakes = encodedStakes
        game = encodedGame
    }
    
    func savedButtonPressed(viewModel: SessionsListViewModel) {
        
        guard self.isValidForm else { return }
        viewModel.addSession(location: self.location,
                             game: self.game,
                             stakes: self.stakes,
                             date: self.startTime,
                             profit: computedProfit - (Int(self.expenses) ?? 0),
                             notes: self.notes,
                             startTime: self.startTime,
                             endTime: self.endTime,
                             // Tournament metrics in the app look to 'expenses' for Buy-In data.
                             expenses: sessionType == .cash ? Int(self.expenses) ?? 0 : Int(buyIn) ?? 0,
                             isTournament: sessionType == .tournament,
                             entrants: Int(self.entrants) ?? 0,
                             highHandBonus: Int(self.highHandBonus) ?? 0,
                             buyIn: Int(self.buyIn) ?? 0,
                             cashOut: Int(self.cashOut) ?? 0)
        
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
