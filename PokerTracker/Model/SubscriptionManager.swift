//
//  SubscriptionManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/22/23.
//

import Foundation
import RevenueCat
import SwiftUI
import AdSupport

class SubscriptionManager: NSObject, ObservableObject, PurchasesDelegate {
    
    @Published var isSubscribed = false
    @AppStorage("rcUserId") private var rcUserID: String = ""
    
    override init() {
        super.init()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_nzoxZjFOdCffwvTEKrdMdDqjfzO")
        Purchases.shared.delegate = self
        Purchases.shared.attribution.collectDeviceIdentifiers()
        
        rcUserID = Purchases.shared.appUserID
        print("Your RevenueCat UserID is: " + rcUserID)
        
        Task {
            await self.checkSubscriptionStatus()
            Purchases.shared.attribution.collectDeviceIdentifiers()
        }
    }
    
    @MainActor
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
        } catch {
            print("Problem checking subscription status: \(error)")
        }
    }
    
    // This listener should be able to handle whenever an Offer Code is redeemed
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        // Handle the updated CustomerInfo
        Task {
            await MainActor.run {
                self.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
            }
        }
    }
}
