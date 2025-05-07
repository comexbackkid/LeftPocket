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
            
            if columns.count == 46 {
                
                // Extract only relevant data and create a PokerSession object
                let date = convertToDate(columns[1].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let startTime = convertToDate(columns[1].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date().modifyTime(minutes: -180)
                let endTime = convertToDate(columns[2].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let limit = columns[7].trimmingCharacters(in: .init(charactersIn: "\""))
                let game = limit + " " + columns[6].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel_v2(name: columns[9].trimmingCharacters(in: .init(charactersIn: "\"")))
                let buyIn = Int((Double(columns[13].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0).rounded())
                let cashRebuyAmount = Int((Double(columns[18].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0).rounded())
                let cashGameTotalBuyin = buyIn + cashRebuyAmount
                let cashOut = Int((Double(columns[14].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0).rounded())
                let profit = Int((Double(columns[15].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0).rounded())
                let stakesPart1 = Double(columns[22].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0
                let stakesPart2 = Double(columns[23].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0
                let stakes = "\(stakesPart1.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(stakesPart1)) : String(stakesPart1))/\(stakesPart2.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(stakesPart2)) : String(stakesPart2))"
                let expenses = Int(columns[27]) ?? 0
                let handsPerHour = Int(columns[28]) ?? 25
                let bounties = Int(columns[20]) ?? 0
                let tournamentRebuyCount = Int(columns[17]) ?? 0
                
                // Tournament Data
                let sessionType = columns[5].trimmingCharacters(in: .init(charactersIn: "\""))
                let finish = Int(columns[29]) ?? 0
                let entrants = Int(columns[30]) ?? 0
                
                // Need to figure out how to handle the buyIn being the same as expenses
                
                let session = PokerSession_v2(location: location,
                                              date: date,
                                              startTime: startTime,
                                              endTime: endTime,
                                              game: game,
                                              stakes: sessionType == "Tournament" ? "" : stakes,
                                              buyIn: sessionType == "Tournament" ? buyIn : cashGameTotalBuyin,
                                              cashOut: cashOut,
                                              profit: profit,
                                              expenses: expenses,
                                              notes: "",
                                              tags: [],
                                              highHandBonus: 0,
                                              handsPerHour: handsPerHour,
                                              totalPausedTime: nil,
                                              isTournament: sessionType == "Tournament" ? true : false,
                                              rebuyCount: sessionType == "Tournament" ? tournamentRebuyCount : nil,
                                              bounties: bounties,
                                              tournamentSize: sessionType == "Tournament" ? "MTT" : nil,
                                              tournamentSpeed: sessionType == "Tournament" ? "Standard" : nil,
                                              entrants: sessionType == "Tournament" ? entrants : nil,
                                              finish: sessionType == "Tournament" ? finish : nil,
                                              tournamentDays: sessionType == "Tournament" ? 1 : nil,
                                              startTimeDayTwo: nil,
                                              endTimeDayTwo: nil,
                                              stakers: nil)
                
                importedSessions.append(session)
                
            } else {
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
            }
        }
        
        return importedSessions
    }
    
    // MARK: Pokerbase Import
    
    func importCSVFromPokerbase(data: Data, selectedStakes: String) throws -> [PokerSession_v2] {
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        var importedSessions: [PokerSession_v2] = []
        
        // Iterate through rows in the CSV ignoring the first row
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex]
            let columns = row.components(separatedBy: ";")
            print(row)
            
            if columns.count == 6 {
                
                // Extract only relevant data and create a PokerSession object
                let location = LocationModel_v2(name: columns[2])
                let stakes = selectedStakes
                let date = convertToDateFromPokerbase(columns[0]) ?? Date()
                let profit = Int(columns[5]) ?? 0
                let startTime = convertToDateFromPokerbase(columns[0]) ?? Date().modifyTime(minutes: -180)
                let endTime = convertToDateFromPokerbase(columns[1]) ?? Date()
                let game = "NL Texas Hold Em"
                let buyIn = 0
                let cashOut = profit
                let expenses = Int(columns[4]) ?? 0
                
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
                                              handsPerHour: 25,
                                              totalPausedTime: nil,
                                              isTournament: false,
                                              rebuyCount: nil,
                                              bounties: nil,
                                              tournamentSize: nil,
                                              tournamentSpeed: nil,
                                              entrants: nil,
                                              finish: nil,
                                              tournamentDays: nil,
                                              startTimeDayTwo: nil,
                                              endTimeDayTwo: nil,
                                              stakers: nil)
                
                importedSessions.append(session)
                
            } else {
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
            }
        }
        
        return importedSessions
    }
    
    // MARK: Left Pocket Import
    
    func importCSVFromLeftPocket(data: Data) throws -> [PokerSession_v2] {
        
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
            var columns = row.components(separatedBy: ",")
            
            if columns.count == 11 {
                columns.append("")
            }
            
            if columns.count == 19 {
                // TBD code importing old session data type
                let game = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel_v2(name: columns[0].trimmingCharacters(in: .init(charactersIn: "\"")))
                let stakes = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let date = convertToDateFromLeftPocket(columns[3].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let profit = Int(columns[7]) ?? 0
                let startTime = convertToDateFromLeftPocket(columns[9].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date().modifyTime(minutes: -180)
                let endTime = convertToDateFromLeftPocket(columns[10].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let expenses = Int(columns[8].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let highHandBonus = Int(columns[16]) ?? 0
                let buyIn = Int(columns[4]) ?? 0
                let cashOut = Int(columns[5]) ?? 0
                let tags = columns[17].trimmingCharacters(in: .init(charactersIn: "\""))
                
                // Tournament Data
                let isTournament = columns[11].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[14].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let tournamentRebuyDollarValue = Int(columns[6].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let rebuyCount = Int(safeDivide(numerator: Double(tournamentRebuyDollarValue), denominator: Double(buyIn)))
                let finish = Int(columns[15].trimmingCharacters(in: .init(charactersIn: "\"")))
                let size = columns[12].trimmingCharacters(in: .init(charactersIn: "\""))
                let speed = columns[13].trimmingCharacters(in: .init(charactersIn: "\""))
                let days = 1

                let oldSession = PokerSession_v2(location: location,
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
                                                 tags: tags.isEmpty ? [] : [tags],
                                                 highHandBonus: highHandBonus,
                                                 handsPerHour: 25,
                                                 totalPausedTime: nil,
                                                 isTournament: isTournament == "TRUE" || isTournament == "true" ? true : false,
                                                 rebuyCount: isTournament == "TRUE" || isTournament == "true" ? rebuyCount : nil,
                                                 bounties: nil,
                                                 tournamentSize: isTournament == "TRUE" || isTournament == "true" ? size : nil,
                                                 tournamentSpeed: isTournament == "TRUE" || isTournament == "true" ? speed : nil,
                                                 entrants: isTournament == "TRUE" || isTournament == "true" ? entrants : nil,
                                                 finish: isTournament == "TRUE" || isTournament == "true" ? finish : nil,
                                                 tournamentDays: isTournament == "TRUE" || isTournament == "true" ? days : nil,
                                                 startTimeDayTwo: nil,
                                                 endTimeDayTwo: nil,
                                                 stakers: nil)
                
                importedSessions.append(oldSession)
                
                
            } else if columns.count == 23 {
                // Extract only relevant data and create a PokerSession object
                let game = columns[4].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel_v2(name: columns[3].trimmingCharacters(in: .init(charactersIn: "\"")))
                let stakes = columns[5].trimmingCharacters(in: .init(charactersIn: "\""))
                let date = convertToDateFromLeftPocket(columns[0].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let profit = Int(columns[8]) ?? 0
                let startTime = convertToDateFromLeftPocket(columns[1].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date().modifyTime(minutes: -180)
                let endTime = convertToDateFromLeftPocket(columns[2].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let expenses = Int(columns[9].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let highHandBonus = Int(columns[10]) ?? 0
                let buyIn = Int(columns[6]) ?? 0
                let cashOut = Int(columns[7]) ?? 0
                let tags = columns[21].trimmingCharacters(in: .init(charactersIn: "\""))
                
                // Tournament Data
                let isTournament = columns[11].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[19].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let rebuyCount = Int(columns[16].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                let finish = Int(columns[20].trimmingCharacters(in: .init(charactersIn: "\"")))
                let size = columns[17].trimmingCharacters(in: .init(charactersIn: "\""))
                let speed = columns[18].trimmingCharacters(in: .init(charactersIn: "\""))
                let isMultiDay = columns[12].trimmingCharacters(in: .init(charactersIn: "\""))
                let days = Int(columns[13].trimmingCharacters(in: .init(charactersIn: "\"")))
                let startTimeDayTwo = convertToDateFromLeftPocket(columns[14].trimmingCharacters(in: .init(charactersIn: "\"")))
                let endTimeDayTwo = convertToDateFromLeftPocket(columns[15].trimmingCharacters(in: .init(charactersIn: "\"")))
                
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
                                              tags: tags.isEmpty ? [] : [tags],
                                              highHandBonus: highHandBonus,
                                              handsPerHour: 25,
                                              totalPausedTime: nil,
                                              isTournament: isTournament == "TRUE" || isTournament == "true" ? true : false,
                                              rebuyCount: isTournament == "TRUE" || isTournament == "true" ? rebuyCount : nil,
                                              bounties: nil,
                                              tournamentSize: isTournament == "TRUE" || isTournament == "true" ? size : nil,
                                              tournamentSpeed: isTournament == "TRUE" || isTournament == "true" ? speed : nil,
                                              entrants: isTournament == "TRUE" || isTournament == "true" ? entrants : nil,
                                              finish: isTournament == "TRUE" || isTournament == "true" ? finish : nil,
                                              tournamentDays: isTournament == "TRUE" || isTournament == "true" ? days : nil,
                                              startTimeDayTwo: isMultiDay == "TRUE" || isMultiDay == "true" ? startTimeDayTwo : nil,
                                              endTimeDayTwo: isMultiDay == "TRUE" || isMultiDay == "true" ? endTimeDayTwo : nil,
                                              stakers: nil)
                
                importedSessions.append(session)
            }
            
            else {
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
                let profit = Int((Double(columns[9].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0).rounded())
                let startTime = convertToDateFromPokerAnalytics(columns[0].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date().modifyTime(minutes: -180)
                let endTime = convertToDateFromPokerAnalytics(columns[1].trimmingCharacters(in: .init(charactersIn: "\""))) ?? Date()
                let expenses = Int(columns[10].trimmingCharacters(in: .init(charactersIn: "\""))) ?? 0
                
                // Tournament Data
                let sessionType = columns[3].trimmingCharacters(in: .init(charactersIn: "\""))
                let entrants = Int(columns[23].trimmingCharacters(in: .init(charactersIn: "\"")))
                let size = columns[21].trimmingCharacters(in: .init(charactersIn: "\""))
                let finish = Int(columns[25].trimmingCharacters(in: .init(charactersIn: "\"")))
                let buyIn = Int((Double(columns[6].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0).rounded())
                let cashOut = Int((Double(columns[7].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? 0).rounded())
                
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
                                              handsPerHour: 25,
                                              totalPausedTime: nil,
                                              isTournament: sessionType == "Tournament" ? true : false,
                                              rebuyCount: sessionType == "Tournament" ? 0 : nil,
                                              bounties: nil,
                                              tournamentSize: sessionType == "Tournament" ? size : nil,
                                              tournamentSpeed: sessionType == "Tournament" ? "Standard" : nil,
                                              entrants: sessionType == "Tournament" ? entrants : nil,
                                              finish: sessionType == "Tournament" ? finish : nil,
                                              tournamentDays: sessionType == "Tournament" ? 1 : nil,
                                              startTimeDayTwo: nil,
                                              endTimeDayTwo: nil,
                                              stakers: nil)
                
                importedSessions.append(session)
                
            } else {
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
            }
        }
        
        return importedSessions
    }
    
    // MARK: Bink Poker Import
    
    func importCSVFromBinkPoker(data: Data) throws -> [PokerSession_v2] {
        
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        var importedSessions: [PokerSession_v2] = []
        
        // Ignore the first row (indexes), start at the second row
        for rowIndex in 1..<rows.count {
            
            let row = rows[rowIndex]
            let columns = row.components(separatedBy: ",")
            
            if columns.count == 14 {
                
                // Extract only relevant data and create a PokerSession object
                let dateString = columns[0].trimmingCharacters(in: .init(charactersIn: "\""))
                let durationString = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let startDate = convertToDateFromBinkPoker(dateString) ?? Date()
                let startTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: startDate) ?? Date().modifyTime(minutes: -300)
                
                // Parse the duration and calculate end time
                let duration = Double(durationString) ?? 0.0
                let durationHours = Int(duration)
                let durationMinutes = Int((duration.truncatingRemainder(dividingBy: 1)) * 60)
                let endTime = Calendar.current.date(byAdding: .hour, value: durationHours, to: Calendar.current.date(byAdding: .minute, value: durationMinutes, to: startTime) ?? Date()) ?? Date()
                let limit = columns[9].trimmingCharacters(in: .init(charactersIn: "\""))
                let game = limit + " " + columns[8].trimmingCharacters(in: .init(charactersIn: "\""))
                let location = LocationModel_v2(name: columns[7].trimmingCharacters(in: .init(charactersIn: "\"")))
                let stakes = columns[4].trimmingCharacters(in: .init(charactersIn: "\""))
                let buyInString = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let buyIn = Int(Double(buyInString) ?? 0)
                let cashOutString = columns[3].trimmingCharacters(in: .init(charactersIn: "\""))
                let cashOut = Int(Double(cashOutString) ?? 0)
                let profit = cashOut - buyIn
                let expensesString = columns[10].trimmingCharacters(in: .init(charactersIn: "\""))
                let expenses = Int(Double(expensesString) ?? 0)
                
                // Tournament Data
                let sessionType = columns[5].trimmingCharacters(in: .init(charactersIn: "\""))
                
                let session = PokerSession_v2(location: location,
                                              date: startDate,
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
                                              handsPerHour: 25,
                                              totalPausedTime: nil,
                                              isTournament: sessionType == "Tournament" ? true : false,
                                              rebuyCount: nil,
                                              bounties: nil,
                                              tournamentSize: sessionType == "Tournament" ? "MTT" : nil,
                                              tournamentSpeed: sessionType == "Tournament" ? "Standard" : nil,
                                              entrants: nil,
                                              finish: nil,
                                              tournamentDays: sessionType == "Tournament" ? 1 : nil,
                                              startTimeDayTwo: nil,
                                              endTimeDayTwo: nil,
                                              stakers: nil)
                
                importedSessions.append(session)
                
            } else {
                print("Column count: \(columns.count)")
                throw ImportError.parsingFailed
            }
        }
        
        return importedSessions
    }
    
    // MARK: DATE CONVERSIONS
    
    // Bink Poker date conversion (e.g. "02/12/2025")
    func convertToDateFromBinkPoker(_ rawDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // Matches "02/12/2025"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Standardized date parsing
        dateFormatter.timeZone = TimeZone.current // Adjust to the user's timezone
        
        if let date = dateFormatter.date(from: rawDate) {
            return date
        } else {
            print("Error: Unable to convert string to Date.")
            return nil
        }
    }
    
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
        let formats = ["M/d/yyyy H:mm:ss", "M/d/yyyy H:mm"]
        let formatter = DateFormatter()
        formatter.locale    = Locale(identifier: "en_US_POSIX")
        formatter.timeZone  = .current
        for fmt in formats {
            formatter.dateFormat = fmt
            if let d = formatter.date(from: rawDate) {
                return d
            }
        }
        
        print("ERROR: couldn’t parse “\(rawDate)”")
        return nil
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
