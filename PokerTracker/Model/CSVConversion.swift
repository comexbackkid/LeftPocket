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
    @Published var successfulMsg: String?

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
        
        var csvText = "Location,Game,Stakes,Date,Buy In, Cash Out,Profit,Expenses,Start Time,End Time,Tournament,Entrants,High Hand Bonus,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        // Each string field in the CSV is enclosed in double quotes to ensure that commas within the text do not interfere with the CSV structure.
        for session in data {
            let location = "\"\(session.location.name)\""
            let game = "\"\(escapeQuotes(session.game))\""
            let stakes = "\"\(escapeQuotes(session.stakes))\""
            let date = "\"\(dateFormatter.string(from: session.date))\""
            let profit = "\(session.profit)"
            let expenses = "\"\(session.expenses ?? 0)\""
            let startTime = "\"\(dateFormatter.string(from: session.startTime))\""
            let endTime = "\"\(dateFormatter.string(from: session.endTime))\""
            let isTournament = "\"\(session.isTournament ?? false)\""
            let entrants = "\"\(session.entrants ?? 0)\""
            let highHandBonus = "\(session.highHandBonus ?? 0)"
            let notes = ""
            let buyIn = session.buyIn != nil ? "\(session.buyIn!)" : ""
            let cashOut = session.cashOut != nil ? "\(session.cashOut!)" : ""
            
            let rowText = "\(location),\(game),\(stakes),\(date),\(buyIn),\(cashOut),\(profit),\(expenses),\(startTime),\(endTime),\(isTournament),\(entrants),\(highHandBonus),\(notes)\n"
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
                return "There are no sessions to export."
            case .exportFailed:
                return "There was an error exporting your data."
            }
        }
    }
}
