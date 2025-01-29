//
//  MigrationHandler.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/23/25.
//

import Foundation

class MigrationHandler {
    
    static func migratePokerSessionModel() -> [PokerSession_v2]? {

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let oldSessionsURL = documentsURL.appendingPathComponent("sessions.json")
        let newSessionsURL = documentsURL.appendingPathComponent("sessions_v2.json")
        
        do {
            // Step 1: Load old Sessions
            let oldData = try Data(contentsOf: oldSessionsURL)
            let oldSessions = try JSONDecoder().decode([PokerSession].self, from: oldData)
            
            // Step 2: Migrate each old Session to the new model
            let newSessions = oldSessions.map { oldSession -> PokerSession_v2 in
                PokerSession_v2(id: oldSession.id,
                                location: convertToLocationModelV2(oldSession.location),
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
                                rebuyCount: oldSession.rebuyCount,
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
            
            print("Migration successful! New Session_v2 data saved to \(newSessionsURL)")
            return newSessions
            
        } catch {
            print("Failed to migrate Sessions. Error: \(error)")
            return nil
        }
    }
    
    static func migrateLocationModel() -> [LocationModel_v2]? {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let oldLocationsURL = documentsURL.appendingPathComponent("locations.json")
        let newLocationsURL = documentsURL.appendingPathComponent("locations_v2.json")
        let imagesDirectory = documentsURL.appendingPathComponent("LocationImages")
        
        // Step 1: Create the images directory
        do {
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            print("Failed to create LocationImages directory: \(error)")
            return nil
        }
        
        do {
            // Step 2: Load old locations
            let oldData = try Data(contentsOf: oldLocationsURL)
            let oldLocations = try JSONDecoder().decode([LocationModel].self, from: oldData)
            
            // Step 3: Migrate each old location to the new structure
            let newLocations = oldLocations.map { oldLocation -> LocationModel_v2 in
                var imagePath: String? = nil
                
                // Save the image data to the file system if it exists
                if let imageData = oldLocation.importedImage {
                    let fileName = "\(oldLocation.id).jpg"
                    let imageFileURL = imagesDirectory.appendingPathComponent(fileName)
                    
                    do {
                        try imageData.write(to: imageFileURL)
                        imagePath = fileName
                        
                    } catch {
                        print("Failed to save image for Location: \(oldLocation.name): \(error)")
                    }
                }
                
                // TODO: What happens with the two sets of default Locations, is it overwritten but just with the same ID and image?
                return LocationModel_v2(id: oldLocation.id,
                                        name: oldLocation.name,
                                        localImage: oldLocation.localImage.isEmpty ? nil : oldLocation.localImage,
                                        importedImage: imagePath
                )
            }
            
            // Step 4: Save the migrated locations to the new file
            let newData = try JSONEncoder().encode(newLocations)
            try newData.write(to: newLocationsURL)
            
            print("Location migration successful! New data saved to: \(newLocationsURL)")
            return newLocations
            
        } catch {
            print("Failed to migrate Locations. Error: \(error)")
            return nil
        }
    }
    
    private static func convertToLocationModelV2(_ oldLocation: LocationModel) -> LocationModel_v2 {
        var imagePath: String? = nil
        
        if let imageData = oldLocation.importedImage {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imagesDirectory = documentsURL.appendingPathComponent("LocationImages")
            
            if !fileManager.fileExists(atPath: imagesDirectory.path) {
                try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            // Save image
            let imageFileName = "\(UUID().uuidString).jpg"
            let imageFileURL = imagesDirectory.appendingPathComponent(imageFileName)
            
            do {
                try imageData.write(to: imageFileURL)
                imagePath = imageFileName
                
            } catch {
                print("Failed to save image for Location: \(oldLocation.name): \(error)")
            }
        }
        
        return LocationModel_v2(
            id: oldLocation.id,
            name: oldLocation.name,
            localImage: oldLocation.localImage.isEmpty ? nil : oldLocation.localImage,
            importedImage: imagePath
        )
    }
}
