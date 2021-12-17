//
//  NewSessionViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/27/21.
//

import SwiftUI

final class NewSessionViewModel: ObservableObject {
    
    @Published var location: LocationModel = LocationModel(name: "", imageURL: "")
    @Published var game: String = ""
    @Published var stakes: String = ""
    @Published var profit: String = ""
    @Published var positiveNegative: String = "+"
    @Published var notes: String = ""
    @Published var startTime: Date = Date().modifyTime(minutes: -300)
    @Published var endTime: Date = Date()
    @Published var presentation: Bool?
    
    @Published var alertItem: AlertItem?
    
    var isValidForm: Bool {
        
        guard !location.name.isEmpty else {
            alertItem = AlertContext.inValidLocation
            return false
        }
        
        guard !game.isEmpty else {
            alertItem = AlertContext.inValidGame
            return false
        }
        
        guard !stakes.isEmpty else {
            alertItem = AlertContext.inValidStakes
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
                             profit: Int(self.profit) ?? 0,
                             notes: self.notes,
                             startTime: self.startTime,
                             endTime: self.endTime)
        
        // Only after the form checks out will the presentation be set to false and passed into the Binding in our View
        self.presentation = false
    }
}
