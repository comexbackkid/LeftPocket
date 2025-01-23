//
//  MigrationHandler.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/23/25.
//

import Foundation

class MigrationHandler {
    
    // TODO: Handle LocationModel as well
    static func migratePokerSessionModel() {

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let oldSessionsURL = documentsURL.appendingPathComponent("sessions.json")
        let newSessionsURL = documentsURL.appendingPathComponent("sessions_v2.json")
        
        do {
            // Step 1: Load old sessions
            let oldData = try Data(contentsOf: oldSessionsURL)
            let oldSessions = try JSONDecoder().decode([PokerSession].self, from: oldData)
            
            // Step 2: Migrate each old session to the new structure
            let newSessions = oldSessions.map { oldSession -> PokerSession_v2 in
                PokerSession_v2(
                    id: oldSession.id,
                    location: oldSession.location,
                    date: oldSession.date,
                    startTime: oldSession.startTime,
                    endTime: oldSession.endTime,
                    game: oldSession.game,
                    stakes: oldSession.stakes,
                    buyIn: oldSession.buyIn ?? 0,
                    cashOut: oldSession.cashOut ?? oldSession.profit,
                    profit: oldSession.profit,
                    expenses: (oldSession.isTournament != true ? oldSession.expenses : 0) ?? 0,
                    notes: oldSession.notes,
                    tags: oldSession.tags ?? [],
                    highHandBonus: oldSession.highHandBonus ?? 0,
                    // Tournament Specific Data
                    isTournament: oldSession.isTournament ?? false,
                    rebuyCount: oldSession.rebuyCount ?? 0,
                    tournamentSize: oldSession.tournamentSize,
                    tournamentSpeed: oldSession.tournamentSpeed,
                    entrants: oldSession.entrants,
                    finish: oldSession.finish,
                    tournamentDays: oldSession.tournamentDays,
                    startTimeDayTwo: oldSession.startTimeDayTwo,
                    endTimeDayTwo: oldSession.endTimeDayTwo
                )
            }
            
            let newData = try JSONEncoder().encode(newSessions)
            try newData.write(to: newSessionsURL)
            
            print("Migration successful! New data saved to \(newSessionsURL)")
            
        } catch {
            print("Failed to migrate sessions. Error: \(error)")
        }
    }
}
