//
//  CSVImport.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/4/24.
//

import SwiftUI
import Foundation

class CSVImporter {
    
    // MARK: Poker Income Import
    
    func importCashCSVFromPokerIncome(data: Data) throws -> [PokerSession] {
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        var importedSessions: [PokerSession] = []
        
        // Iterate through rows in the CSV ignoring the first 1 rows
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex]
            let columns = row.components(separatedBy: ",")
            let numberFormatter = NumberFormatter()
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            
            // Can we use a guard statement that just ignores columns that don't match 44?
            if columns.count == 18 {
                
                // Extract only relevant data and create a PokerSession object
                let game = columns[5].trimmingCharacters(in: .init(charactersIn: "\""))
                let limit = columns[6].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel(name: columns[7].trimmingCharacters(in: .init(charactersIn: "\"")), localImage: "", imageURL: "")
                let stakes = columns[17].trimmingCharacters(in: .whitespacesAndNewlines)
                let date = convertToDateFromPokerIncome(columns[0].trimmingCharacters(in: .init(charactersIn: "\"")))
                let profit = numberFormatter.number(from: columns[10])?.intValue
                let notes = columns[11].trimmingCharacters(in: .init(charactersIn: "\""))
                let startTime = convertToDateFromPokerIncome(columns[0].trimmingCharacters(in: .init(charactersIn: "\"")))
                let endTime = convertToDateFromPokerIncome(columns[1].trimmingCharacters(in: .init(charactersIn: "\"")))
                let expenses = Int(columns[15])
                let buyIn = numberFormatter.number(from: columns[8])?.intValue
                let cashOut = numberFormatter.number(from: columns[9])?.intValue
                
                // Need to figure out how to handle the buyIn being the same as expenses
                let session = PokerSession(location: location,
                                           game: limit + " \(game)",
                                           stakes: stakes,
                                           date: date ?? Date(),
                                           profit: profit ?? 0,
                                           notes: notes,
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: expenses,
                                           isTournament: false,
                                           entrants: nil,
                                           finish: nil,
                                           highHandBonus: nil,
                                           buyIn: buyIn,
                                           cashOut: cashOut,
                                           rebuyCount: nil,
                                           tournamentSize: nil,
                                           tournamentSpeed: nil,
                                           tags: nil)
                
                importedSessions.append(session)
                
            } else {
                
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
                
            }
        }
        
        return importedSessions
        
    }
    
    func importTournamentCSVFromPokerIncome(data: Data) throws -> [PokerSession] {
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        var importedSessions: [PokerSession] = []
        
        // Iterate through rows in the CSV ignoring the first 1 rows
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex]
            let columns = row.components(separatedBy: ",")
            let numberFormatter = NumberFormatter()
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            
            if columns.count == 21 {
                
                // Extract only relevant data and create a PokerSession object
                let date = convertToDateFromPokerIncome(columns[0])
                let startTime = convertToDateFromPokerIncome(columns[0])
                let endTime = convertToDateFromPokerIncome(columns[1])
                let game = columns[5]
                let limit = columns[6]
                let location = LocationModel(name: columns[7], localImage: "", imageURL: "")
                let profit = numberFormatter.number(from: columns[10])?.intValue
                let notes = columns[11]
                let entrants = Int(columns[18])
                let finish = Int(columns[20])
                let buyIn = numberFormatter.number(from: columns[8])?.intValue
                let cashOut = numberFormatter.number(from: columns[9])?.intValue
                let tournamentSize = columns[17]
                
                // Need to figure out how to handle the buyIn being the same as expenses
                let session = PokerSession(location: location,
                                           game: limit + " \(game)",
                                           stakes: "",
                                           date: date ?? Date(),
                                           profit: profit ?? 0,
                                           notes: notes,
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: buyIn,
                                           isTournament: true,
                                           entrants: entrants,
                                           finish: finish,
                                           highHandBonus: nil,
                                           buyIn: buyIn,
                                           cashOut: cashOut,
                                           rebuyCount: nil,
                                           tournamentSize: tournamentSize == "Sit & Go" ? tournamentSize : "MTT",
                                           tournamentSpeed: "Standard",
                                           tags: nil)
                
                importedSessions.append(session)
                
            } else {
                
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
                
            }
        }
        
        return importedSessions
    }
    
    // MARK: Poker Bankroll Tracker Import
    
    func importCSVFromPokerBankrollTracker(data: Data) throws -> [PokerSession_v2] {
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        var importedSessions: [PokerSession_v2] = []
        
        // Ignore the first 2 rows (indexes), start at the third row
        for rowIndex in 2..<rows.count {
            
            let row = rows[rowIndex]
            let columns = row.components(separatedBy: ",")
            
            if columns.count == 44 {
                
                // Extract only relevant data and create a PokerSession object
                let limit = columns[6].trimmingCharacters(in: .init(charactersIn: "\""))
                let game = limit + " " + columns[5].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel_v2(name: columns[7].trimmingCharacters(in: .init(charactersIn: "\"")))
                let stakesPart1 = columns[20]
                let stakesPart2 = columns[21]
                let stakes = "\(stakesPart1)/\(stakesPart2)"
                let date = convertToDate(columns[0].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let profit = Int(columns[11]) ?? 0
                let startTime = convertToDate(columns[0].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date().modifyTime(minutes: -180)
                let endTime = convertToDate(columns[1].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let expenses = Int(columns[27]) ?? 0
                let buyIn = Int(columns[9]) ?? 0
                let cashOut = Int(columns[10]) ?? 0
                
                // Tournament Data
                let sessionType = columns[4].trimmingCharacters(in: .init(charactersIn: "\""))
                let finish = Int(columns[30])
                let entrants = Int(columns[31])
                
                // Need to figure out how to handle the buyIn being the same as expenses
                
                let session = PokerSession_v2(location: location,
                                              date: date,
                                              startTime: startTime,
                                              endTime: endTime,
                                              game: game,
                                              stakes: stakes,
                                              buyIn: buyIn,
                                              cashOut: cashOut,
                                              profit: profit,
                                              expenses: expenses,
                                              notes: "",
                                              tags: [],
                                              highHandBonus: 0,
                                              isTournament: sessionType == "Tournament" ? true : false,
                                              rebuyCount: nil,
                                              tournamentSize: sessionType == "Tournament" ? "MTT" : nil,
                                              tournamentSpeed: sessionType == "Tournament" ? "Standard" : nil,
                                              entrants: sessionType == "Tournament" ? entrants : nil,
                                              finish: sessionType == "Tournament" ? finish : nil,
                                              tournamentDays: sessionType == "Tournament" ? 1 : nil,
                                              startTimeDayTwo: nil,
                                              endTimeDayTwo: nil)
                
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
                                           tournamentSpeed: nil,
                                           tags: nil)
                
                importedSessions.append(session)
                
            } else {
                
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
                
            }
        }
        
        return importedSessions
        
    }
    
    // MARK: Left Pocket IMPORT
    
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
            if row.isEmpty { continue }
            var columns = row.components(separatedBy: ",")
            
            if columns.count == 11 {
                columns.append("")
            }
           
            if columns.count == 19 {
                
                // Extract only relevant data and create a PokerSession object
                let game = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel(name: columns[0].trimmingCharacters(in: .init(charactersIn: "\"")), localImage: "", imageURL: "")
                let stakes = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let date = convertToDateFromLeftPocket(columns[3].trimmingCharacters(in: .init(charactersIn: "\"")))
                let profit = columns[7]
                let notes = columns[18].trimmingCharacters(in: .init(charactersIn: "\""))
                let startTime = convertToDateFromLeftPocket(columns[9].trimmingCharacters(in: .init(charactersIn: "\"")))
                let endTime = convertToDateFromLeftPocket(columns[10].trimmingCharacters(in: .init(charactersIn: "\"")))
                let expenses = Int(columns[8].trimmingCharacters(in: .init(charactersIn: "\"")))
                let highHandBonus = columns[16]
                let buyIn = columns[4]
                let cashOut = columns[5]
                let tags = columns[17].trimmingCharacters(in: .init(charactersIn: "\""))
                
                // Tournament Data
                let isTournament = columns[11].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[14].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let tournamentBuyIn = Int(columns[4].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let tournamentRebuys = Int(columns[6]) ?? 0
                let tournamentRebuyCount = Int(safeDivide(numerator: Double(columns[6]), denominator: Double(columns[4])))
                let tournamentFinish = Int(columns[15].trimmingCharacters(in: .init(charactersIn: "\"")))
                let tournamentSize = columns[12].trimmingCharacters(in: .init(charactersIn: "\""))
                let tournamentSpeed = columns[13].trimmingCharacters(in: .init(charactersIn: "\""))
                
                // Need to figure out how to handle the buyIn being the same as expenses
                let session = PokerSession(location: location,
                                           game: game,
                                           stakes: stakes,
                                           date: date ?? Date(),
                                           profit: Int(profit) ?? 0,
                                           notes: notes,
                                           startTime: startTime ?? Date().modifyTime(minutes: -360),
                                           endTime: endTime ?? Date(),
                                           expenses: isTournament == "true" ? tournamentBuyIn + tournamentRebuys : expenses,
                                           isTournament: isTournament == "true" ? true : false,
                                           entrants: entrants,
                                           finish: tournamentFinish,
                                           highHandBonus: Int(highHandBonus) ?? 0,
                                           buyIn: Int(buyIn),
                                           cashOut: Int(cashOut),
                                           rebuyCount: tournamentRebuyCount,
                                           tournamentSize: tournamentSize,
                                           tournamentSpeed: tournamentSpeed,
                                           tags: tags.isEmpty ? nil : [tags])
                
                importedSessions.append(session)
                
            } else {
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
            }
        }
        
        return importedSessions
    }
    
    // MARK: Poker Analytics 6 Import
    
    func importCSVFromPokerAnalytics(data: Data) throws -> [PokerSession_v2] {
        
        let csvString: String? = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
        
        guard let csvContent = csvString else {
            throw ImportError.invalidData
        }
        
        var importedSessions: [PokerSession_v2] = []
        let rows = csvContent.components(separatedBy: "\n")
        
        // Iterate through rows in the CSV ignoring the first row
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            if row.isEmpty { continue }
            let columns = row.components(separatedBy: ",")

            if columns.count == 27 {
                
                // Extract only relevant data and create a PokerSession object
                let limit = columns[12].trimmingCharacters(in: .init(charactersIn: "\""))
                let gameType = columns[13].trimmingCharacters(in: .init(charactersIn: "\""))
                let game = limit + " \(gameType)"
                let location = LocationModel_v2(name: columns[15].trimmingCharacters(in: .init(charactersIn: "\"")))
                let stakes = columns[19].trimmingCharacters(in: .init(charactersIn: "\""))
                let date = convertToDateFromPokerAnalytics(columns[0].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let profit = Int(columns[9].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let startTime = convertToDateFromPokerAnalytics(columns[0].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date().modifyTime(minutes: -180)
                let endTime = convertToDateFromPokerAnalytics(columns[1].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let expenses = Int(columns[10].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                
                // Tournament Data
                let sessionType = columns[3].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[23].trimmingCharacters(in: .init(charactersIn: "\"")))
                let size = columns[21].trimmingCharacters(in: .init(charactersIn: "\""))
                let finish = Int(columns[25].trimmingCharacters(in: .init(charactersIn: "\"")))
                let buyIn = Int(columns[6].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let cashOut = Int(columns[7].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                
                let session = PokerSession_v2(location: location,
                                              date: date,
                                              startTime: startTime,
                                              endTime: endTime,
                                              game: game,
                                              stakes: stakes,
                                              buyIn: buyIn,
                                              cashOut: cashOut,
                                              profit: profit,
                                              expenses: expenses,
                                              notes: "",
                                              tags: [],
                                              highHandBonus: 0,
                                              isTournament: sessionType == "Tournament" ? true : false,
                                              rebuyCount: sessionType == "Tournament" ? 0 : nil,
                                              tournamentSize: sessionType == "Tournament" ? size : nil,
                                              tournamentSpeed: sessionType == "Tournament" ? "Standard" : nil,
                                              entrants: sessionType == "Tournament" ? entrants : nil,
                                              finish: sessionType == "Tournament" ? finish : nil,
                                              tournamentDays: sessionType == "Tournament" ? 1 : nil,
                                              startTimeDayTwo: nil,
                                              endTimeDayTwo: nil)
                
                importedSessions.append(session)
                
            } else {
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
            }
        }
        
        return importedSessions
    }
    
    // MARK: DATE CONVERSIONS
    
    // Poker Income date conversion
    func convertToDateFromPokerIncome(_ rawDate: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures the date format is interpreted correctly
        dateFormatter.timeZone = TimeZone.current // Adjusts for the device's current timezone
        
        if let date = dateFormatter.date(from: rawDate) {
            return date
            
        } else {
            print("Error: Unable to convert string to Date.")
            return nil
        }
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
    
    // MARK: HELPER FUNCTIONS
    
    func safeDivide(numerator: Double?, denominator: Double?) -> Double {
        guard let numerator = numerator, let denominator = denominator, denominator != 0 else {
            return 0
        }
        return numerator / denominator
    }
    
    enum ImportError: Error {
        case invalidData
        case parsingFailed
        case saveFailed
    }
}
