//
//  SessionDefaultsView.functions.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/22/25.
//

import SwiftUI

extension SessionDefaultsView {
    
    func resetUserDefaults() {
        
        sessionType = nil
        selectedBankrollID = nil
        location = LocationModel_v2(name: "")
        stakes = ""
        game = ""
        size = ""
        speed = ""
        currency = .USD
        askLiveSessionEachTime = false
        showHandsPerHourOnNewSessionView = false
        handsPerHour = 25
        
        let defaults = UserDefaults.standard
        let resetResult = Result {
            
            defaults.removeObject(forKey: "sessionTypeDefault")
            defaults.removeObject(forKey: "bankrollDefault")
            defaults.removeObject(forKey: "locationDefault")
            defaults.removeObject(forKey: "stakesDefault")
            defaults.removeObject(forKey: "gameDefault")
            defaults.removeObject(forKey: "currencyDefault")
            defaults.removeObject(forKey: "tournamentSizeDefault")
            defaults.removeObject(forKey: "tournamentSpeedDefault")
            defaults.removeObject(forKey: "askLiveSessionEachTime")
            defaults.removeObject(forKey: "showHandsPerHourOnNewSessionView")
            defaults.removeObject(forKey: "handsPerHourDefault")
        }
        
        switch resetResult {
        case .success:
            resultMessage = "Session Defaults reset."
        case .failure(let error):
            resultMessage = "\(error.localizedDescription)"
        }
    }
    
    func saveToUserDefaults() {
        
        let defaults = UserDefaults.standard
        let saveResult = Result {
            
            if let encodedSessionType = try? JSONEncoder().encode(sessionType) {
                defaults.set(encodedSessionType, forKey: "sessionTypeDefault")
            }
            
            if let encodedBankroll = try? JSONEncoder().encode(selectedBankrollID) {
                defaults.set(encodedBankroll, forKey: "bankrollDefault")
            }
            
            if let encodedLocation = try? JSONEncoder().encode(location) {
                defaults.set(encodedLocation, forKey: "locationDefault")
            }
            
            if let encodedCurrency = try? JSONEncoder().encode(currency) {
                defaults.set(encodedCurrency, forKey: "currencyDefault")
            }
            
            defaults.set(stakes, forKey: "stakesDefault")
            defaults.set(game, forKey: "gameDefault")
            defaults.set(size, forKey: "tournamentSizeDefault")
            defaults.set(speed, forKey: "tournamentSpeedDefault")
            defaults.set(askLiveSessionEachTime, forKey: "askLiveSessionEachTime")
            defaults.set(showHandsPerHourOnNewSessionView, forKey: "showHandsPerHourOnNewSessionView")
            defaults.set(handsPerHour, forKey: "handsPerHourDefault")
            vm.getUserCurrency()
        }
        
        switch saveResult {
        case .success:
            resultMessage = "Session Defaults have been saved."
            showAlertModal = true
            
        case .failure(let error):
            errorMessage = "\(error.localizedDescription)"
        }
    }
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
        // Load Currency
        if let encodedCurrency = defaults.object(forKey: "currencyDefault") as? Data,
           let decodedCurrency = try? JSONDecoder().decode(CurrencyType.self, from: encodedCurrency) {
            currency = decodedCurrency
        } else {
            currency = .USD // Provide a default value if missing
        }
        
        // Load Session Type
        if let encodedSessionType = defaults.object(forKey: "sessionTypeDefault") as? Data,
           let decodedSessionType = try? JSONDecoder().decode(SessionType.self, from: encodedSessionType) {
            sessionType = decodedSessionType
        } else {
            sessionType = nil
        }
        
        // Load Bankroll
        if let encodedBankroll = defaults.data(forKey: "bankrollDefault"), let savedID = try? JSONDecoder().decode(UUID.self, from: encodedBankroll) {
            // 2) Check that it still exists in your live bankroll array
            if vm.bankrolls.contains(where: { $0.id == savedID }) {
                selectedBankrollID = savedID
                
            } else {
                defaults.removeObject(forKey: "bankrollDefault")
                selectedBankrollID = nil
            }
            
        } else {
            selectedBankrollID = nil
        }
        
        // Load Location
        if let encodedLocation = defaults.object(forKey: "locationDefault") as? Data,
           let decodedLocation = try? JSONDecoder().decode(LocationModel_v2.self, from: encodedLocation) {
            location = decodedLocation
        } else {
            location = LocationModel_v2(name: "")
        }
        
        if let handsPerHour = defaults.object(forKey: "handsPerHourDefault") as? Int {
            self.handsPerHour = handsPerHour
        } else {
            handsPerHour = 25
        }
        
        // Load Stakes, Game, & Tournament Defaults
        stakes = defaults.string(forKey: "stakesDefault") ?? ""
        game = defaults.string(forKey: "gameDefault") ?? ""
        size = defaults.string(forKey: "tournamentSizeDefault") ?? ""
        speed = defaults.string(forKey: "tournamentSpeedDefault") ?? ""
        askLiveSessionEachTime = defaults.bool(forKey: "askLiveSessionEachTime")
        showHandsPerHourOnNewSessionView = defaults.bool(forKey: "showHandsPerHourOnNewSessionView")
    }
}
