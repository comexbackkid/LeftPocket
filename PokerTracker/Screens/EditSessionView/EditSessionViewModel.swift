//
//  EditSessionViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/25/25.
//

import Foundation
import SwiftUI

final class EditSessionViewModel: ObservableObject {
    
    @Published var location: LocationModel_v2 = DefaultData.defaultLocation
    @Published var selectedBankroll: BankrollSelection = .default
    @Published var selectedBankrollID: UUID?
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
    @Published var handsPerHour = 25
    @Published var addLocationIsShowing = false
    @Published var addStakesIsShowing = false
    @Published var alertItem: AlertItem?
    @Published var sessionType: SessionType = .cash
    @Published var tournamentDays: String = ""
    @Published var startTimeDayTwo: Date = Date()
    @Published var endTimeDayTwo: Date = Date()
    @Published var stakers: [Staker] = []
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isValidForm: Bool {
        
        var error: AlertItem? = nil

        if sessionType == .cash {
            if stakes.isEmpty {
                error = AlertContext.inValidStakes
            } else if buyIn.isEmpty {
                error = AlertContext.invalidBuyIn
            }
        } else {
            if speed.isEmpty {
                error = AlertContext.invalidSpeed
            } else if size.isEmpty {
                error = AlertContext.invalidSize
            } else if entrants.isEmpty {
                error = AlertContext.invalidEntrants
            } else if finish.isEmpty {
                error = AlertContext.invalidFinish
            } else if Int(finish)! >= Int(entrants)! {
                error = AlertContext.invalidFinishPlace
            } else if buyIn.isEmpty {
                error = AlertContext.invalidBuyIn
            }
        }
        
        if isPad {
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: buyIn)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cashOut)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: finish)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: entrants)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: rebuyCount)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: highHandBonus)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: expenses)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
        }

        if endTime <= startTime {
            error = AlertContext.invalidEndTime
        } else if endTime.timeIntervalSince(startTime) <= 60 {
            error = AlertContext.invalidDuration
        }
   
        if let error = error {
            alertItem = error
            return false
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
                return (Int(cashOut) ?? 0) - (Int(buyIn) ?? 0)
                
            } else {
                let tournamentWinnings = (Int(cashOut) ?? 0) + (Int(bounties) ?? 0)
                
                // Calculate total staker percentage
                let totalPercentageSold = stakers.reduce(0.0) { $0 + $1.percentage }
                
                // Corrected Player Buy-in Cost (subtract stakers' share of both buy-in and rebuys)
                let totalBuyIn = (Int(buyIn) ?? 0) + tournamentRebuys
                let stakersContribution = Double(totalBuyIn) * totalPercentageSold
                let playerBuyInCost = totalBuyIn - Int(stakersContribution)
                
                // Compute the total action sold (based on winnings split, NOT buy-in)
                let totalActionSold = stakers.reduce(0.0) { total, staker in
                    return total + (Double(tournamentWinnings) * staker.percentage)
                }
                
                // Compute the markup earned (extra money from backers)
                let markupEarned = stakers.reduce(0.0) { total, staker in
                    let stakeCostWithoutMarkup = (Double(buyIn) ?? 0) * staker.percentage
                    let markupAmount = stakeCostWithoutMarkup * ((staker.markup ?? 1.0) - 1.0)
                    return total + markupAmount
                }
                
                return tournamentWinnings - playerBuyInCost + Int(markupEarned) - Int(totalActionSold)
            }
        }

        let session = PokerSession_v2(location: location,
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
                                      handsPerHour: handsPerHour,
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
        
        // Save to the correct bankroll
        switch selectedBankroll {
        case .default:
            viewModel.sessions.append(session)
            viewModel.sessions.sort(by: { $0.date > $1.date })
            
        case .custom(let id):
            viewModel.addSession(session, to: id)
            
        case .all:
            break // shouldn't happen, but if it does, we might want to ignore it
        }
        
        // Delete old session (wherever it came from)
        if let existingID = viewModel.bankrollID(for: editedSession) {
            viewModel.removeSession(editedSession, from: existingID)
        } else {
            viewModel.sessions.removeAll(where: { $0.id == editedSession.id })
        }
    }
}
