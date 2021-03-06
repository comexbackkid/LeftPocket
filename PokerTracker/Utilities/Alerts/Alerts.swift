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
    
    static let inValidLocation = AlertItem(title: Text("Invalid Form"),
                                           message: Text("Please select a Location."),
                                           dismissButton: .default(Text("OK")))
    
    static let inValidGame = AlertItem(title: Text("Invalid Form"),
                                       message: Text("Please select the Game type."),
                                       dismissButton: .default(Text("OK")))
    
    static let inValidStakes = AlertItem(title: Text("Invalid Form"),
                                         message: Text("Please select the correct Stakes."),
                                         dismissButton: .default(Text("OK")))
    
    static let inValidDate = AlertItem(title: Text("Invalid Form"),
                                       message: Text("Please select a Date."),
                                       dismissButton: .default(Text("OK")))
}
