//
//  SessionModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import Foundation
import SwiftUI

// MARK: OLD POKERSESSION STRUCT

struct PokerSession: Hashable, Codable, Identifiable {
    var id = UUID()
    let location: LocationModel
    let game: String
    let stakes: String
    let date: Date
    let profit: Int
    let notes: String
    let startTime: Date
    let endTime: Date
    let expenses: Int?
    let isTournament: Bool?
    let entrants: Int?
    let finish: Int?
    let highHandBonus: Int?
    let buyIn: Int?
    let cashOut: Int?
    let rebuyCount: Int?
    let tournamentSize: String?
    let tournamentSpeed: String?
    let tags: [String]?
    var tournamentDays: Int?
    var startTimeDayTwo: Date?
    var endTimeDayTwo: Date?
    
    // Individual Session playing time formatted for Session Detail View
    var playingTIme: String {
        return sessionDuration.abbreviated(duration: self.sessionDuration)
    }
    
    // Individual Session duration
    var sessionDuration: DateComponents {

        let dayOneDuration = Calendar.current.dateComponents([.hour, .minute], from: self.startTime, to: self.endTime)
        
        // Check if it's a Multi-Day Tournament
        if let tournamentDays = self.tournamentDays, tournamentDays > 1 {
            if let startTimeDayTwo = self.startTimeDayTwo, let endTimeDayTwo = self.endTimeDayTwo {

                let dayTwoDuration = Calendar.current.dateComponents([.hour, .minute], from: startTimeDayTwo, to: endTimeDayTwo)
                
                // Sum the durations from day one and day two
                let totalMinutes = (dayOneDuration.minute ?? 0) + (dayTwoDuration.minute ?? 0)
                let totalHours = (dayOneDuration.hour ?? 0) + (dayTwoDuration.hour ?? 0) + (totalMinutes / 60)
                let remainingMinutes = totalMinutes % 60
                
                return DateComponents(hour: totalHours, minute: remainingMinutes)
                
            } else {
                return dayOneDuration
            }
        } else {
            return dayOneDuration
        }
    }
    
    // Individual Session hourly rate
    var hourlyRate: Int {
        let totalHours = sessionDuration.durationInHours == 0 ? 1 : sessionDuration.durationInHours
        return Int(round(Float(self.profit) / totalHours))
    }
    
    // Individual Session number of big blinds won
    var bigBlindsWon: Double {
        guard let lastSlashIndex = stakes.lastIndex(of: "/"),
              let bigBlind = Int(stakes[lastSlashIndex...].trimmingCharacters(in: .punctuationCharacters)) else {
              
            return 0
        }
        
        let bigBlindWin = Float(self.profit) / Float(bigBlind)
        return Double(bigBlindWin)
    }
    
    // Individual Session big blind per hour rate
    var bigBlindPerHour: Double {
        guard let lastSlashIndex = stakes.lastIndex(of: "/"),
              let bigBlind = Int(stakes[lastSlashIndex...].trimmingCharacters(in: .punctuationCharacters)) else {
              
            return 0
        }
        
        let totalHours = sessionDuration.durationInHours == 0 ? 1 : sessionDuration.durationInHours
        let bigBlindWin = Float(self.profit) / Float(bigBlind)
        return Double(bigBlindWin) / Double(totalHours)
    }
}

// MARK: NEW POKERSESSION STRUCT

struct DefaultData {
    static let defaultLocation = LocationModel(name: "TBD", localImage: "empty-location", imageURL: "")
}
