//
//  SessionModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import Foundation
import SwiftUI

// MARK: OLD POKERSESSION MODEL

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
        return sessionDuration.durationShortHand()
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

// MARK: NEW POKERSESSION MODEL

struct PokerSession_v2: Hashable, Codable, Identifiable {
    var id = UUID()
    let location: LocationModel_v2
    let date: Date
    let startTime: Date
    let endTime: Date
    let game: String
    let stakes: String
    let buyIn: Int
    let cashOut: Int
    let profit: Int
    let expenses: Int
    let notes: String
    let tags: [String]
    let highHandBonus: Int
    let handsPerHour: Int?
    let totalPausedTime: TimeInterval?
    
    // Tournament Handling
    let isTournament: Bool
    let rebuyCount: Int?
    let bounties: Int?
    let tournamentSize: String?
    let tournamentSpeed: String?
    let entrants: Int?
    let finish: Int?
    let tournamentDays: Int?
    let startTimeDayTwo: Date?
    let endTimeDayTwo: Date?
    let stakers: [Staker]?
    
    // Individual Session duration
    var sessionDuration: DateComponents {
        // Calculate raw duration (including any paused time)
        let rawDayOneDuration = Calendar.current.dateComponents([.hour, .minute, .second],
                                                              from: self.startTime,
                                                              to: self.endTime)
        
        // Convert raw duration to seconds
        let rawDayOneSeconds = (rawDayOneDuration.hour ?? 0) * 3600 +
                              (rawDayOneDuration.minute ?? 0) * 60 +
                              (rawDayOneDuration.second ?? 0)
        
        // Adjust for paused time if available
        let adjustedDayOneSeconds: Int
        if let pausedTime = totalPausedTime, pausedTime > 0 {
            adjustedDayOneSeconds = max(0, rawDayOneSeconds - Int(pausedTime))
        } else {
            adjustedDayOneSeconds = rawDayOneSeconds
        }
        
        // Handle multi-day tournaments
        guard let tournamentDays = self.tournamentDays, tournamentDays > 1,
              let startTimeDayTwo = self.startTimeDayTwo,
              let endTimeDayTwo = self.endTimeDayTwo else {
            // Single day session - return adjusted duration
            let hours = adjustedDayOneSeconds / 3600
            let minutes = (adjustedDayOneSeconds % 3600) / 60
            return DateComponents(hour: hours, minute: minutes)
        }
        
        // Multi-day tournament - calculate day two duration
        let rawDayTwoDuration = Calendar.current.dateComponents([.hour, .minute, .second],
                                                              from: startTimeDayTwo,
                                                              to: endTimeDayTwo)
        
        let rawDayTwoSeconds = (rawDayTwoDuration.hour ?? 0) * 3600 +
                             (rawDayTwoDuration.minute ?? 0) * 60 +
                             (rawDayTwoDuration.second ?? 0)
        
        // Sum adjusted durations from both days
        let totalSeconds = adjustedDayOneSeconds + rawDayTwoSeconds
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        return DateComponents(hour: hours, minute: minutes)
    }
    
    
    
    
//    var sessionDuration: DateComponents {
//        
//        let dayOneDuration = Calendar.current.dateComponents([.hour, .minute], from: self.startTime, to: self.endTime)
//        
//        // Check if it's a Multi-Day Tournament, might want to re-label some variables here given new functionality in NewSessionViewModel
//        if let tournamentDays = self.tournamentDays, tournamentDays > 1 {
//            if let startTimeDayTwo = self.startTimeDayTwo, let endTimeDayTwo = self.endTimeDayTwo {
//                
//                let dayTwoDuration = Calendar.current.dateComponents([.hour, .minute], from: startTimeDayTwo, to: endTimeDayTwo)
//                
//                // Sum the durations from day one and day two
//                let totalMinutes = (dayOneDuration.minute ?? 0) + (dayTwoDuration.minute ?? 0)
//                let totalHours = (dayOneDuration.hour ?? 0) + (dayTwoDuration.hour ?? 0) + (totalMinutes / 60)
//                let remainingMinutes = totalMinutes % 60
//                
//                return DateComponents(hour: totalHours, minute: remainingMinutes)
//                
//            } else {
//                return dayOneDuration
//            }
//        } else {
//            return dayOneDuration
//        }
//    }
    
    
    
    
    
//    var sessionDuration: DateComponents {
//        
//        let dayOneDuration = Calendar.current.dateComponents([.hour, .minute], from: self.startTime, to: self.endTime)
//        
//        var adjustedDuration = dayOneDuration
//        if let pausedTime = totalPausedTime {
//            let pausedComponents = Calendar.current.dateComponents([.hour, .minute], from: Date(timeIntervalSinceReferenceDate: 0), to: Date(timeIntervalSinceReferenceDate: pausedTime))
//            let totalMinutes = (dayOneDuration.minute ?? 0) - (pausedComponents.minute ?? 0)
//            let totalHours = (dayOneDuration.hour ?? 0) - (pausedComponents.hour ?? 0) + (totalMinutes / 60)
//            let remainingMinutes = totalMinutes % 60
//            adjustedDuration = DateComponents(hour: totalHours, minute: remainingMinutes)
//        }
//        
//        // Check if it's a Multi-Day Tournament, might want to re-label some variables here given new functionality in NewSessionViewModel
//        if let tournamentDays = self.tournamentDays, tournamentDays > 1 {
//            if let startTimeDayTwo = self.startTimeDayTwo, let endTimeDayTwo = self.endTimeDayTwo {
//                
//                let dayTwoDuration = Calendar.current.dateComponents([.hour, .minute], from: startTimeDayTwo, to: endTimeDayTwo)
//                
//                // Sum the durations from day one and day two
//                let totalMinutes = (adjustedDuration.minute ?? 0) + (dayTwoDuration.minute ?? 0)
//                let totalHours = (adjustedDuration.hour ?? 0) + (dayTwoDuration.hour ?? 0) + (totalMinutes / 60)
//                let remainingMinutes = totalMinutes % 60
//                
//                return DateComponents(hour: totalHours, minute: remainingMinutes)
//                
//            } else {
//                return adjustedDuration
//            }
//        } else {
//            return adjustedDuration
//        }
//    }
    
    // Individual Session playing time formatted for Session Detail View
    var playingTIme: String {
        return sessionDuration.durationShortHand()
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

struct Staker: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let percentage: Double
    let markup: Double?
}
