//
//  NewSessionViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/27/21.
//

import SwiftUI

final class NewSessionViewModel: ObservableObject {
    
    @Published var location: String = ""
    @Published var game: String = ""
    @Published var stakes: String = ""
    @Published var profit: String = ""
    @Published var notes: String = ""
    @Published var date = Date()
    @Published var startTime: Date = Date().adding(minutes: -60)
    @Published var endTime: Date = Date()
    
    @Published var alertItem: AlertItem?
    
    var isValidForm: Bool {
        
        guard !location.isEmpty else {
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
}
