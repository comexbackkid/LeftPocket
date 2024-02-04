//
//  CSVImport.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/4/24.
//

import SwiftUI
import Foundation

//class ImportViewModel: ObservableObject {
//    
//    @Published var importedSessions: [PokerSession]?
//    
//    enum ImportError: Error {
//            case invalidData
//            case parsingFailed
//            case saveFailed
//        }
//    
//    static func importCSV(data: Data) throws -> [PokerSession] {
//        
//            guard let csvString = String(data: data, encoding: .utf8) else {
//                throw ImportError.invalidData
//            }
//
//            let rows = csvString.components(separatedBy: "\n")
//            var importedSessions: [PokerSession] = []
//
//            for row in rows {
//                
//                let columns = row.components(separatedBy: ",")
//
//                // Extract relevant data and create a PokerSession object
//                let game = columns[5]
//                let location = LocationModel(name: columns[7], localImage: "", imageURL: "")
//                let stakesPart1 = columns[2]
//                let stakesPart2 = columns[3]
//                let stakes = "\(stakesPart1)/\(stakesPart2)"
//                let date = convertToDate(columns[0])
//                let profit = Int(columns[11])
//                let notes = columns[39]
//                let startTime = convertToDate(columns[0])
//                let endTime = convertToDate(columns[1])
//                let expenses = Int(columns[27])
//                
//                if let date = date,
//                   let profit = profit,
//                   let startTime = startTime,
//                   let endTime = endTime {
//                    
//                    let session = PokerSession(
//                        location: location,
//                        game: game,
//                        stakes: stakes,
//                        date: date,
//                        profit: profit,
//                        notes: notes,
//                        startTime: startTime,
//                        endTime: endTime,
//                        expenses: expenses,
//                        isTournament: false,
//                        entrants: 0
//                    )
//                    
//                    importedSessions.append(session)
//                }
//            }
//
//            return importedSessions
//        }
//    
//    private func saveImportedSessions() throws {
//        
//            guard let sessions = importedSessions else {
//                throw ImportError.invalidData
//            }
//
//            let jsonData = try JSONEncoder().encode(sessions)
//            let jsonFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sessions.json")
//
//            try jsonData.write(to: jsonFileURL)
//        }
//    
//    static func convertToDate(_ rawDate: String) -> Date? {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            return dateFormatter.date(from: rawDate)
//        }
//    
//}
