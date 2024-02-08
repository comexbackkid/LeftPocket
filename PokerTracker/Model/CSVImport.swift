//
//  CSVImport.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/4/24.
//

import SwiftUI
import Foundation

class CSVImporter {
    
    enum ImportError: Error {
        case invalidData
        case parsingFailed
        case saveFailed
    }
    
    func importCSV(data: Data) throws -> [PokerSession] {
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        var importedSessions: [PokerSession] = []
        
        // Iterate through rows in the CSV ignoring the first 2 rows
        for rowIndex in 2..<rows.count {
            
            let row = rows[rowIndex]
            let columns = row.components(separatedBy: ",")
            
            // Can we use a guard statement that just ignores columns that don't match 44?
            if columns.count == 44 {
                
                // Extract only relevant data and create a PokerSession object
                let game = columns[5].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel(name: columns[7].trimmingCharacters(in: .init(charactersIn: "\"")), localImage: "", imageURL: "")
                let stakesPart1 = columns[20]
                let stakesPart2 = columns[21]
                let stakes = "\(stakesPart1)/\(stakesPart2)"
                let date = convertToDate(columns[0].trimmingCharacters(in: .init(charactersIn: "\"")))
                let profit = columns[11]
                let notes = columns[39].trimmingCharacters(in: .init(charactersIn: "\""))
                let startTime = convertToDate(columns[0].trimmingCharacters(in: .init(charactersIn: "\"")))
                let endTime = convertToDate(columns[1].trimmingCharacters(in: .init(charactersIn: "\"")))
                let expenses = Int(columns[27])
                
                // Need a more elegant way to handle the optionals here. Date especially.
                // What are we doing with handling tournaments?
                // This probably won't work because if you have expenses it changes column count to 45. Why? Is it nil data in the exported CSV?
                let session = PokerSession(location: location,
                                           game: game,
                                           stakes: stakes,
                                           date: date ?? Date(),
                                           profit: Int(profit) ?? 0,
                                           notes: notes,
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: expenses,
                                           isTournament: false,
                                           entrants: 0)
                
                importedSessions.append(session)
                print("Columns: \(columns.count)")
                
            } else {
                
                print("Columns are fucked up. Count: \(columns.count)")
            }
        }
        
        return importedSessions
    }
    
    func convertToDate(_ rawDate: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: rawDate) {
            return date
            
        } else {
            print("Error: Unable to convert string to Date.")
            return nil
        }
    }
}
