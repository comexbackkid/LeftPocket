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

    static func exportCSV(from sessions: [PokerSession_v2]) throws -> URL {
        
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
    
    static private func convertToCSV(data: [PokerSession_v2]) -> String {
        var csvText = "Date,Start Time,End Time,Location,Game,Stakes,Buy In,Cash Out,Profit,Expenses,High Hands,Tournament,Multi-Day,Days,Rebuy Count,Size,Speed,Entrants,Finish,Tags,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        /// Each string field in the CSV is enclosed in double quotes to ensure that commas within the text do not interfere with the CSV structure
        /// No Cash Rebuys right now because we aren't saving them in the model, so only Tournament rebuys
        
        for session in data {
            let date = "\"\(dateFormatter.string(from: session.date))\""
            let startTime = "\"\(dateFormatter.string(from: session.startTime))\""
            let endTime = "\"\(dateFormatter.string(from: session.endTime))\""
            let location = "\"\(session.location.name)\""
            let game = "\"\(escapeQuotes(session.game))\""
            let stakes = "\"\(escapeQuotes(session.stakes))\""
            let buyIn = "\(session.buyIn)"
            let cashOut = "\(session.cashOut)"
            let profit = "\(session.profit)"
            let expenses = "\"\(session.expenses)\""
            let highHandBonus = "\(session.highHandBonus)"
            let isTournament = "\"\(session.isTournament)\""
            let isMultiDayTournament = session.tournamentDays ?? 1 > 1 ? "true" : "false"
            // Need help on days
            let days = session.tournamentDays != nil ? "\(session.tournamentDays!)" : ""
            let rebuyCount = session.rebuyCount != nil ? "\(session.rebuyCount!)" : ""
            let size = session.tournamentSize != nil ? "\"\(session.tournamentSize!)\"" : ""
            let speed = session.tournamentSpeed != nil ? "\"\(session.tournamentSpeed!)\"" : ""
            let entrants = session.entrants != nil ? "\"\(session.entrants!)\"" : ""
            let finish = session.finish != nil ? "\(session.finish!)" : ""
            let tags = session.tags.first ?? ""
            let notes = ""
            
            let rowText = "\(date),\(startTime),\(endTime),\(location),\(game),\(stakes),\(buyIn),\(cashOut),\(profit),\(expenses),\(highHandBonus),\(isTournament),\(isMultiDayTournament),\(days),\(rebuyCount),\(size),\(speed),\(entrants),\(finish),\(tags),\(notes)\n"
            
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
                return "There are no Sessions to export."
            case .exportFailed:
                return "There was an error exporting your data."
            }
        }
    }
}
