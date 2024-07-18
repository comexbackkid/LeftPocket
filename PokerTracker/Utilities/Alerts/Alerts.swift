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
                                           message: Text("Please select a Location. To add your own, select Add New Location from the dropdown menu."),
                                           dismissButton: .default(Text("OK")))
    
    static let inValidGame = AlertItem(title: Text("Invalid Form"),
                                       message: Text("Please select the Game Type."),
                                       dismissButton: .default(Text("OK")))
    
    static let inValidStakes = AlertItem(title: Text("Invalid Form"),
                                         message: Text("Please select your Stakes. To add your own, select Add Stakes from the dropdown menu."),
                                         dismissButton: .default(Text("OK")))
    
    static let inValidDate = AlertItem(title: Text("Invalid Form"),
                                       message: Text("Please select a Date."),
                                       dismissButton: .default(Text("OK")))
    
    static let invalidSpeed = AlertItem(title: Text("Invalid Form"), 
                                        message: Text("Please select the Tournament Speed."),
                                        dismissButton: .default(Text("OK")))
    
    static let invalidSize = AlertItem(title: Text("Invalid Form"), 
                                       message: Text("Please select the Tournament Size."),
                                       dismissButton: .default(Text("OK")))
    
    static let invalidFinish = AlertItem(title: Text("Invalid Form"),
                                         message: Text("Please enter where you finished."),
                                         dismissButton: .default(Text("OK")))
    
    static let invalidFinishPlace = AlertItem(title: Text("Invalid Form"),
                                         message: Text("Your finish must be lower than the number of Entrants."),
                                         dismissButton: .default(Text("OK")))
    
    static let invalidEntrants = AlertItem(title: Text("Invalid Form"),
                                           message: Text("Please enter the number of Entrants."),
                                           dismissButton: .default(Text("OK")))
    
    static let invalidBuyIn = AlertItem(title: Text("Invalid Form"),
                                        message: Text("Please enter your Buy In amount."),
                                        dismissButton: .default(Text("OK")))
    
    static let invalidEndTime = AlertItem(title: Text("Invalid Form"),
                                          message: Text("Your End Time cannot precede the Start Time."),
                                          dismissButton: .default(Text("OK")))
    
    static let invalidDuration = AlertItem(title: Text("Invalid Form"),
                                          message: Text("Your Session duration must exceed one minute."),
                                          dismissButton: .default(Text("OK")))
    
    static let inValidLocationName = AlertItem(title: Text("Invalid Form"),
                                           message: Text("Please enter a Location name."),
                                           dismissButton: .default(Text("OK")))
    
    static let invalidTransactionType = AlertItem(title: Text("Invalid Form"), 
                                                  message: Text("Please select a Transaction type."),
                                                  dismissButton: .default(Text("OK")))
    
    static let invalidAmount = AlertItem(title: Text("Invalid Form"),
                                         message: Text("Please enter a Transaction amount."),
                                         dismissButton: .default(Text("OK")))
}
