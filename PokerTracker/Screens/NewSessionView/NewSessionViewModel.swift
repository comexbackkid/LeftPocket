//
//  NewSessionViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/27/21.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import TipKit

final class NewSessionViewModel: ObservableObject {
    
    @Published var selectedBankrollID: UUID?
    @Published var location: LocationModel_v2 = LocationModel_v2(name: "")
    @Published var game: String = ""
    @Published var stakes: String = ""
    @Published var profit: String = ""
    @Published var positiveNegative: String = "+"
    @Published var notes: String = ""
    @Published var times: [DateInterval] = [DateInterval(start: .now.addingTimeInterval(-3600 * 5), duration: 18000)]
    @Published var expenses: String = ""
    @Published var presentation: Bool?
    @Published var sessionType: SessionType?
    @Published var entrants: String = ""
    @Published var alertItem: AlertItem?
    @Published var buyIn: String = ""
    @Published var cashOut: String = ""
    @Published var highHandBonus: String = ""
    @Published var rebuyCount: String = ""
    @Published var cashRebuys: String = ""
    @Published var bounties: String = ""
    @Published var finish: String = ""
    @Published var size: String = ""
    @Published var speed: String = ""
    @Published var tags: String = ""
    @Published var staking: Bool = false
    @Published var handsPerHour: Int = 25
    @Published var actionSold: String = ""
    @Published var stakerName: String = ""
    @Published var stakerList: [Staker] = []
    @Published var markup: Double = 1.0
    @Published var showHandsPerHour: Bool = false
    @Published var hasBounties: Bool = false
    @Published var multiDayToggle: Bool = false
    @Published var addDay: Bool = false
    @Published var noMoreDays: Bool = false
    
    init() {
        loadUserDefaults()
    }
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Making sure to include rebuys in profit calculation
    var computedProfit: Int {
        if sessionType == .cash {
            return (Int(cashOut) ?? 0) - (Int(buyIn) ?? 0) - (Int(cashRebuys) ?? 0)
            
        } else {
            let cashOutAmount = Double(Int(cashOut) ?? 0)
            let bountiesAmount = Double(Int(bounties) ?? 0)
            let totalWinnings = cashOutAmount + bountiesAmount
            let totalBuyIn = Double(Int(buyIn) ?? 0) + Double(tournamentRebuys)
            
            // How much player pays to stakers from prize money
            let totalStakerPayout = stakerList.reduce(0.0) { $0 + (totalWinnings * $1.percentage) }
            
            // How much stakers contributed to entry
            let stakerContribution = totalBuyIn * stakerList.reduce(0.0) { $0 + $1.percentage }
            
            // Player's share of entry
            let playerBuyInCost = totalBuyIn - stakerContribution
            
            // Markup: money player received from stakers beyond just their % of buy-in
            let markupEarned = stakerList.reduce(0.0) { total, staker in
                let baseStake = Double(Int(buyIn) ?? 0) * staker.percentage
                let markup = (staker.markup ?? 1.0)
                return total + (baseStake * (markup - 1.0))
            }
            
            // Final profit = winnings - stake paid - own entry + markup
            let netProfit = totalWinnings - totalStakerPayout - playerBuyInCost + markupEarned
            
            return Int(netProfit.rounded())
        }
    }
    
    var tournamentDays: Int { times.count }
    
    // Adjusted Start/End Time for Day Two, default to day two's start time if it's only a two-day tournament
    var adjustedStartTimeDayTwo: Date? {
        if times.count > 1 { return times[1].start }
        return nil
    }
    
    // If tournamentDays are greater than two, we'll compute an arbitrary end time for endTimeDayTwo to get an accurate time duration
    var adjustedEndTimeDayTwo: Date? {
        guard let startTimeDayTwo = adjustedStartTimeDayTwo else { return nil }
        
        let totalSecondsPlayed = times.dropFirst().reduce(0) { $0 + $1.duration }
        return startTimeDayTwo.addingTimeInterval(totalSecondsPlayed)
    }
    
    // Adds up the total dollar amount of Tournament rebuys
    var tournamentRebuys: Int {
        guard !rebuyCount.isEmpty else { return 0 }
        
        let buyIn = Int(self.buyIn) ?? 0
        let numberOfRebuys = Int(rebuyCount) ?? 0
        
        return buyIn * numberOfRebuys
    }
    
    // If Tournament action was sold, calculate how much is owed to them if we won
    var totalActionSold: Int {
        if sessionType == .tournament {
            let totalPercentage = stakerList.reduce(0) { $0 + $1.percentage }
            let totalWinnings = (Double(cashOut) ?? 0) + (Double(bounties) ?? 0)
            let amountOwed = totalWinnings * totalPercentage
            return Int(amountOwed)
            
        } else {
            return 0
        }
    }

    // Add name & action amount to the array of [Staker]
    func addStaker(_ name: String, _ action: Double) {
        guard !stakerName.isEmpty, action > 0 else { return }
        let newStaker = Staker(name: name, percentage: (action / 100), markup: self.markup)
        stakerList.append(newStaker)
    }
    
    // Remove selected name from array of [Staker]
    func removeStaker(_ staker: Staker) {
        stakerList.removeAll { $0.id == staker.id }
    }
    
    // Testing new form validation method
    func validateForm() -> Bool {
        var error: AlertItem? = nil

        if sessionType == nil {
            error = AlertContext.invalidSession
        } else if location.name.isEmpty {
            error = AlertContext.inValidLocation
        } else if sessionType == .cash {
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
            } else if multiDayToggle && (tournamentDays < 2 || !noMoreDays) {
                error = AlertContext.invalidTournamentDates
            } else if staking && stakerList.isEmpty {
                error = AlertContext.invalidStaking
            }
        }

        if game.isEmpty {
            error = AlertContext.inValidGame
        } else if times[0].end <= times[0].start {
            error = AlertContext.invalidEndTime
        } else if times[0].end.timeIntervalSince(times[0].start) <= 60 {
            error = AlertContext.invalidDuration
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
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cashRebuys)) else {
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

        if let error = error {
            alertItem = error
            return false
        }

        return true
    }
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
        // Load Session Type
        if let encodedSessionType = defaults.object(forKey: "sessionTypeDefault") as? Data, let decodedSessionType = try? JSONDecoder().decode(SessionType.self, from: encodedSessionType) {
            sessionType = decodedSessionType
        } else {
            sessionType = nil
        }
        
        // Load Location
        if let encodedLocation = defaults.object(forKey: "locationDefault") as? Data, let decodedLocation = try? JSONDecoder().decode(LocationModel_v2.self, from: encodedLocation) {
            location = decodedLocation
        } else {
            location = LocationModel_v2(name: "")
        }
        
        // Load Stakes, Game, & Tournament Defaults
        stakes = defaults.string(forKey: "stakesDefault") ?? ""
        game = defaults.string(forKey: "gameDefault") ?? ""
        size = defaults.string(forKey: "tournamentSizeDefault") ?? ""
        speed = defaults.string(forKey: "tournamentSpeedDefault") ?? ""
        handsPerHour = defaults.object(forKey: "handsPerHourDefault") != nil ? defaults.integer(forKey: "handsPerHourDefault") : 25
        showHandsPerHour = defaults.bool(forKey: "showHandsPerHourOnNewSessionView")
    }
    
    func savedButtonPressed(viewModel: SessionsListViewModel, dismiss: () -> Void) {
        guard self.validateForm() else { return }
        let newSession = PokerSession_v2(location: location,
                                         date: times[0].start,
                                         startTime: times[0].start,
                                         endTime: times[0].end,
                                         game: game,
                                         stakes: stakes,
                                         buyIn: (Int(buyIn) ?? 0) + (sessionType == .cash ? (Int(self.cashRebuys) ?? 0) : 0),
                                         cashOut: Int(cashOut) ?? 0,
                                         profit: computedProfit,
                                         expenses: Int(expenses) ?? 0,
                                         notes: notes,
                                         tags: tags.isEmpty ? [] : [tags],
                                         highHandBonus: Int(highHandBonus) ?? 0,
                                         handsPerHour: handsPerHour,
                                         isTournament: sessionType == .tournament ? true : false,
                                         rebuyCount: Int(rebuyCount) ?? nil,
                                         bounties: Int(bounties) ?? nil,
                                         tournamentSize: !size.isEmpty ? size : nil,
                                         tournamentSpeed: !speed.isEmpty ? speed : nil,
                                         entrants: Int(entrants),
                                         finish: Int(finish),
                                         tournamentDays: sessionType == .tournament ? tournamentDays : nil,
                                         startTimeDayTwo: tournamentDays > 1 ? adjustedStartTimeDayTwo : nil,
                                         endTimeDayTwo: tournamentDays > 1 ? adjustedEndTimeDayTwo : nil,
                                         stakers: sessionType == .tournament && !stakerList.isEmpty ? stakerList : nil)
        
        if let bankrollID = selectedBankrollID {
            viewModel.addSession(newSession, to: bankrollID)
            viewModel.updateBankrollProgressRing()
            viewModel.saveBankrolls()
            viewModel.writeToWidget()
            
        } else {
            viewModel.sessions.append(newSession)
            viewModel.sessions.sort(by: { $0.date > $1.date })
        }
        
        Task { await FilterSessionsTip.sessionCount.donate() }
        dismiss()
        
        if Int(self.profit) ?? 0 > 0 { AppReviewRequest.requestReviewIfNeeded() }
    }
}

enum SessionType: String, Codable { case cash, tournament }
