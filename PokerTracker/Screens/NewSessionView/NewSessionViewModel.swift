//
//  NewSessionViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/27/21.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

final class NewSessionViewModel: ObservableObject {
    
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
    
    enum SessionType { case cash, tournament }
    
    @Published var alertItem: AlertItem?
    
    var isValidForm: Bool {
        
        guard sessionType != nil else {
            alertItem = AlertContext.invalidSession
            return false
        }
        
        guard !location.name.isEmpty else {
            alertItem = AlertContext.inValidLocation
            return false
        }
        
        if sessionType == .cash {
            guard !stakes.isEmpty else {
                alertItem = AlertContext.inValidStakes
                return false
            }
            
        } else {
            guard !entrants.isEmpty else {
                alertItem = AlertContext.invalidEntrants
                return false
            }
            
            guard !expenses.isEmpty else {
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
 
        return true
    }
    
    func savedButtonPressed(viewModel: SessionsListViewModel) {
        
        guard self.isValidForm else { return }
        viewModel.addSession(location: self.location,
                             game: self.game,
                             stakes: self.stakes,
                             date: self.startTime,
                             profit: (Int(self.positiveNegative + self.profit) ?? 0) - (Int(self.expenses) ?? 0),
                             notes: self.notes,
                             startTime: self.startTime,
                             endTime: self.endTime,
                             expenses: Int(self.expenses) ?? 0,
                             isTournament: sessionType == .tournament,
                             entrants: Int(self.entrants) ?? 0)
        
        // Only after the form checks out will the presentation be set to false and passed into the Binding in our View
        self.presentation = false
    }
}
