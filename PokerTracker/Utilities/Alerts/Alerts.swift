//
//  Alerts.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/27/21.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    
    static let invalidSession = AlertItem(title: Text("Invalid Form"),
                                           message: Text("Please select a Session Type."),
                                           dismissButton: .default(Text("OK")))
    
    static let inValidLocation = AlertItem(title: Text("Invalid Form"),
                                           message: Text("Please select a Location."),
                                           dismissButton: .default(Text("OK")))
    
    static let inValidGame = AlertItem(title: Text("Invalid Form"),
                                       message: Text("Please select the Game Type."),
                                       dismissButton: .default(Text("OK")))
    
    static let inValidStakes = AlertItem(title: Text("Invalid Form"),
                                         message: Text("Please select from the Stakes."),
                                         dismissButton: .default(Text("OK")))
    
    static let inValidDate = AlertItem(title: Text("Invalid Form"),
                                       message: Text("Please select a Date."),
                                       dismissButton: .default(Text("OK")))
    
    static let invalidEntrants = AlertItem(title: Text("Invalid Form"),
                                           message: Text("Please enter the number of Entrants."),
                                           dismissButton: .default(Text("OK")))
    
    static let invalidBuyIn = AlertItem(title: Text("Invalid Form"),
                                        message: Text("Please enter Buy-In amount."),
                                        dismissButton: .default(Text("OK")))
    
    static let invalidEndTime = AlertItem(title: Text("Invalid Form"),
                                          message: Text("Your End Time cannot precede the Start Time."),
                                          dismissButton: .default(Text("OK")))
    
    
}
