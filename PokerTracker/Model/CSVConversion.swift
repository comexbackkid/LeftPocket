//
//  CSVConversion.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/5/24.
//

import Foundation
import SwiftUI

class CSVConversion: ObservableObject {
    
    @Published var errorMsg: String?

    // Old Version
//    static func exportCSV(data: [PokerSession]) -> URL? {
//        
//        let csvText = convertToCSV(data: data)
//        let fileURL = getDocumentsDirectory().appendingPathComponent("Year_End_Results.csv", conformingTo: .commaSeparatedText)
//        try? FileManager.default.removeItem(at: fileURL)
//
//        do {
//            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
//            return fileURL
//            
//        } catch {
//            print("Error writing to file: \(error)")
//        }
//        
//        return nil
//    }
    
    // New Version
    // Throws errors now
    static func exportCSV(from sessions: [PokerSession]) throws -> URL {
        
            guard !sessions.isEmpty else {
                throw CSVError.invalidData
            }

            let csvText = convertToCSV(data: sessions)

            do {
                
                let fileURL = try getDocumentsDirectoryNew().appendingPathComponent("Left_Pocket_Sessions.csv")
                try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
                return fileURL
                
            } catch {
                
                throw CSVError.exportFailed
            }
        }

    static private func convertToCSV(data: [PokerSession]) -> String {
        
        var csvText = "Location,Game,Stakes,Date,Profit,Notes,Start Time,End Time,Expenses,Tournament,Entrants\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        // Each string field in the CSV is enclosed in double quotes to ensure that commas within the text do not interfere with the CSV structure.
        for session in data {
                let location = "\"\(session.location.name)\""
                let game = "\"\(escapeQuotes(session.game))\""
                let stakes = "\"\(escapeQuotes(session.stakes))\""
                let date = "\"\(dateFormatter.string(from: session.date))\""
                let profit = "\(session.profit)"
                let notes = "\"\(escapeQuotes(session.notes))\""
                let startTime = "\"\(dateFormatter.string(from: session.startTime))\""
                let endTime = "\"\(dateFormatter.string(from: session.endTime))\""
                let expenses = "\"\(session.expenses ?? 0)\""
                let isTournament = "\"\(session.isTournament ?? false)\""
                let entrants = "\"\(session.entrants ?? 0)\""

                let rowText = "\(location),\(game),\(stakes),\(date),\(profit),\(notes),\(startTime),\(endTime),\(expenses),\(isTournament),\(entrants)\n"
                csvText.append(rowText)
            }
        
        return csvText
    }

    static private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static private func escapeQuotes(_ text: String) -> String {
        return text.replacingOccurrences(of: "\"", with: "\"\"")
    }
    
    private static func getDocumentsDirectoryNew() throws -> URL {
            guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw CSVError.exportFailed
            }
            return directoryURL
        }
}

extension CSVConversion {
    
    enum CSVError: Error, LocalizedError {
        
        case invalidData
        case exportFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidData:
                return "There are no Sessions to export!"
            case .exportFailed:
                return "There was an error exporting your data."
            }
        }
    }
}
