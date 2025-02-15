//
//  EditSessionViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/25/25.
//

import Foundation

final class EditSessionViewModel: ObservableObject {
    
    @Published var location: LocationModel_v2 = DefaultData.defaultLocation
    @Published var date: Date = Date()
    @Published var stakes: String = ""
    @Published var game: String = ""
    @Published var startTime: Date = Date().modifyTime(minutes: -360)
    @Published var endTime: Date = Date()
    @Published var buyIn: String = ""
    @Published var cashOut: String = ""
    @Published var expenses: String = ""
    @Published var notes: String = ""
    @Published var highHandBonus: String = ""
    @Published var entrants: String = ""
    @Published var finish: String = ""
    @Published var speed: String = ""
    @Published var size: String = ""
    @Published var bounties: String = ""
    @Published var rebuyCount: String = ""
    @Published var tags: String = ""
    @Published var addLocationIsShowing = false
    @Published var addStakesIsShowing = false
    @Published var alertItem: AlertItem?
    @Published var sessionType: SessionType = .cash
    @Published var tournamentDays: String = ""
    @Published var startTimeDayTwo: Date = Date()
    @Published var endTimeDayTwo: Date = Date()
    @Published var stakers: [Staker] = []
    
    // TODO: ADD ADDITIONAL CHECKS TO THIS, PERHAPS JUST MAKE IT SIMILAR TO NEWSESSION'S CHECKVALIDFORM FUNCTION
    
    var isValidForm: Bool {
        
        guard endTime > startTime else {
            alertItem = AlertContext.invalidEndTime
            return false
        }
        
        guard endTime.timeIntervalSince(startTime) > 60 else {
            alertItem = AlertContext.invalidDuration
            return false
        }
        
        if sessionType == .tournament {
            guard !entrants.isEmpty else {
                alertItem = AlertContext.invalidEntrants
                return false
            }
            
            guard !finish.isEmpty else {
                alertItem = AlertContext.invalidFinish
                return false
            }
        }
        
        return true
    }
    
    var tournamentRebuys: Int {
        
        guard !rebuyCount.isEmpty else { return 0 }
        
        let buyIn = Int(self.buyIn) ?? 0
        let numberOfRebuys = Int(rebuyCount) ?? 0
        
        return buyIn * numberOfRebuys
    }
    
    var totalActionSold: Int {
        if sessionType == .tournament {
            let totalPercentage = stakers.reduce(0) { $0 + $1.percentage }
            let totalWinnings = (Double(cashOut) ?? 0) + (Double(bounties) ?? 0)
            let amountOwed = totalWinnings * totalPercentage
            return Int(amountOwed)
        } else {
            return 0
        }
    }
    
    // Saves a duplicate of the pokerSession, then deletes the old one
    func saveEditedSession(viewModel: SessionsListViewModel, editedSession: PokerSession_v2) {
        
        var computedProfit: Int {
            if sessionType == .cash {
                return (Int(cashOut) ?? 0) - (Int(buyIn) ?? 0) - (Int(expenses) ?? 0)
            } else {
                let tournamentWinnings = (Int(cashOut) ?? 0) + (Int(bounties) ?? 0)
                return tournamentWinnings - (Int(buyIn) ?? 0) - tournamentRebuys - totalActionSold
            }
        }

        viewModel.addNewSession(location: location,
                                date: startTime,
                                startTime: startTime,
                                endTime: endTime,
                                game: game,
                                stakes: stakes,
                                buyIn: Int(buyIn) ?? 0,
                                cashOut: Int(cashOut) ?? 0,
                                profit: computedProfit,
                                expenses: Int(expenses) ?? 0,
                                notes: notes,
                                tags: tags.isEmpty ? [] : [tags],
                                highHandBonus: Int(highHandBonus) ?? 0,
                                isTournament: sessionType == .tournament ? true : false,
                                rebuyCount: Int(rebuyCount),
                                bounties: Int(bounties),
                                tournamentSize: size,
                                tournamentSpeed: speed,
                                entrants: Int(entrants),
                                finish: Int(finish),
                                tournamentDays: Int(tournamentDays),
                                startTimeDayTwo: startTimeDayTwo,
                                endTimeDayTwo: endTimeDayTwo,
                                stakers: sessionType == .tournament && !stakers.isEmpty ? stakers : nil)
    }
}
