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
    
    // MARK: Poker Bankroll Tracker Import
    
    func importCSVFromPokerBankrollTracker(data: Data) throws -> [PokerSession] {
        
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
                
                // Tournament Data
                let sessionType = columns[4].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[31]) ?? 0
                let buyIn = Int(columns[9]) ?? 0
                
                // Need to figure out how to handle the buyIn being the same as expenses
                let session = PokerSession(location: location,
                                           game: game,
                                           stakes: stakes,
                                           date: date ?? Date(),
                                           profit: Int(profit) ?? 0,
                                           notes: notes,
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: sessionType == "Tournament" ? buyIn : expenses,
                                           isTournament: sessionType == "Tournament" ? true : false,
                                           entrants: entrants,
                                           finish: nil,
                                           highHandBonus: nil,
                                           buyIn: nil,
                                           cashOut: nil,
                                           rebuyCount: nil,
                                           tournamentSize: nil,
                                           tournamentSpeed: nil)
                
                importedSessions.append(session)
                
            } else {
                
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
                
            }
        }
        
        return importedSessions
    }
    
    // MARK: Pokerbase Import
    
    func importCSVFromPokerbase(data: Data, selectedStakes: String) throws -> [PokerSession] {
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        var importedSessions: [PokerSession] = []
        
        // Iterate through rows in the CSV ignoring the first row
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex]
            let columns = row.components(separatedBy: ";")
            print(row)
            
            if columns.count == 6 {
                
                // Extract only relevant data and create a PokerSession object
                let location = LocationModel(name: columns[2], localImage: "", imageURL: "")
                let stakes = selectedStakes
                let date = convertToDateFromPokerbase(columns[0])
                let profit = columns[5]
                let startTime = convertToDateFromPokerbase(columns[0])
                let endTime = convertToDateFromPokerbase(columns[1])
                let expenses = Int(columns[4])
                
                // Need to figure out how to handle the buyIn being the same as expenses
                let session = PokerSession(location: location,
                                           game: "NL Texas Hold Em",
                                           stakes: stakes,
                                           date: date ?? Date(),
                                           profit: Int(profit) ?? 0,
                                           notes: "",
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: expenses,
                                           isTournament: false,
                                           entrants: nil,
                                           finish: nil,
                                           highHandBonus: nil,
                                           buyIn: nil,
                                           cashOut: nil,
                                           rebuyCount: nil,
                                           tournamentSize: nil,
                                           tournamentSpeed: nil)
                
                importedSessions.append(session)
                
            } else {
                
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
                
            }
        }
        
        return importedSessions
        
    }
    
    // MARK: LEFT POCKET IMPORT
    
    func importCSVFromLeftPocket(data: Data) throws -> [PokerSession] {
        
        let csvString: String? = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
        
        guard let csvContent = csvString else {
                throw ImportError.invalidData
            }
        
        var importedSessions: [PokerSession] = []
        let rows = csvContent.components(separatedBy: "\n")
    
        // Iterate through rows in the CSV ignoring the first row
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            // Skip empty rows
            if row.isEmpty { continue }
            var columns = row.components(separatedBy: ",")
            
            if columns.count == 11 {
                columns.append("")
            }
           
            if columns.count == 12 {
                
                // Extract only relevant data and create a PokerSession object
                let game = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel(name: columns[0].trimmingCharacters(in: .init(charactersIn: "\"")), localImage: "", imageURL: "")
                let stakes = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let date = convertToDateFromLeftPocket(columns[3].trimmingCharacters(in: .init(charactersIn: "\"")))
                let profit = columns[4]
                let notes = columns[11].trimmingCharacters(in: .init(charactersIn: "\""))
                let startTime = convertToDateFromLeftPocket(columns[6].trimmingCharacters(in: .init(charactersIn: "\"")))
                let endTime = convertToDateFromLeftPocket(columns[7].trimmingCharacters(in: .init(charactersIn: "\"")))
                let expenses = Int(columns[5].trimmingCharacters(in: .init(charactersIn: "\"")))
                let highHandBonus = columns[10]
                
                // Tournament Data
                let isTournament = columns[8].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[9].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let buyIn = Int(columns[5].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                
                // Need to figure out how to handle the buyIn being the same as expenses
                let session = PokerSession(location: location,
                                           game: game,
                                           stakes: stakes,
                                           date: date ?? Date(),
                                           profit: Int(profit) ?? 0,
                                           notes: notes,
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: isTournament == "true" ? buyIn : expenses,
                                           isTournament: isTournament == "true" ? true : false,
                                           entrants: entrants,
                                           finish: nil,
                                           highHandBonus: Int(highHandBonus) ?? 0,
                                           buyIn: nil,
                                           cashOut: nil,
                                           rebuyCount: nil,
                                           tournamentSize: nil,
                                           tournamentSpeed: nil)
                
                importedSessions.append(session)
                
            } else {
                
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
                
            }
        }
        
        return importedSessions
    }
    
    // MARK: Poker Analytics 6 Import
    
    func importCSVFromPokerAnalytics(data: Data) throws -> [PokerSession] {
        
        let csvString: String? = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
        
        guard let csvContent = csvString else {
                throw ImportError.invalidData
            }
        
        var importedSessions: [PokerSession] = []
        let rows = csvContent.components(separatedBy: "\n")
        
        // Iterate through rows in the CSV ignoring the first row
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            if row.isEmpty { continue }
            let columns = row.components(separatedBy: ",")

            if columns.count == 27 {
                
                // Extract only relevant data and create a PokerSession object
                let game = columns[13].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel(name: columns[15].trimmingCharacters(in: .init(charactersIn: "\"")), localImage: "", imageURL: "")
                let stakes = columns[19].trimmingCharacters(in: .init(charactersIn: "\""))
                let date = convertToDateFromPokerAnalytics(columns[0].trimmingCharacters(in: .init(charactersIn: "\"")))
                let profit = columns[9].trimmingCharacters(in: .init(charactersIn: "\""))
                let notes = ""
                let startTime = convertToDateFromPokerAnalytics(columns[0].trimmingCharacters(in: .init(charactersIn: "\"")))
                let endTime = convertToDateFromPokerAnalytics(columns[1].trimmingCharacters(in: .init(charactersIn: "\"")))
                let expenses = Int(columns[10].trimmingCharacters(in: .init(charactersIn: "\"")))
                
                // Tournament Data
                let sessionType = columns[3].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[23].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let buyIn = Int(columns[6].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                
                // Need to figure out how to handle the buyIn being the same as expenses
                let session = PokerSession(location: location,
                                           game: game,
                                           stakes: stakes,
                                           date: date ?? Date(),
                                           profit: Int(profit) ?? 0,
                                           notes: notes,
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: sessionType == "Tournament" ? buyIn : expenses,
                                           isTournament: sessionType == "Tournament" ? true : false,
                                           entrants: entrants,
                                           finish: nil,
                                           highHandBonus: nil,
                                           buyIn: nil,
                                           cashOut: nil,
                                           rebuyCount: nil,
                                           tournamentSize: nil,
                                           tournamentSpeed: nil)
                
                importedSessions.append(session)
                
            } else {
                
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
                
            }
        }
        
        return importedSessions
    }
    
    // Poker Bankroll Tracker date conversion
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
    
    // Pokerbase date conversion
    func convertToDateFromPokerbase(_ rawDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // It's important for parsing ISO8601
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Optional: Adjust if you need to force a specific timezone

        if let date = dateFormatter.date(from: rawDate) {
            return date
        } else {
            print("Error: Unable to convert string to Date.")
            return nil
        }
    }
    
    // Left Pocket date conversion
    func convertToDateFromLeftPocket(_ rawDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures the date format is interpreted correctly
        dateFormatter.timeZone = TimeZone.current // Adjusts for the device's current timezone

        if let date = dateFormatter.date(from: rawDate) {
            return date
        } else {
            print("Error: Unable to convert string to Date.")
            return nil
        }
    }
    
    // Poker Analytics date conversion
    func convertToDateFromPokerAnalytics(_ rawDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss" // Updated format to match input string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures the date format is interpreted correctly
        dateFormatter.timeZone = TimeZone.current // Adjusts for the device's current timezone

        if let date = dateFormatter.date(from: rawDate) {
            return date
        } else {
            print("Error: Unable to convert string to Date.")
            return nil
        }
    }
}
