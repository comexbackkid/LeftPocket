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

class SubscriptionManager: ObservableObject {

    @Published var isSubscribed = false
    @AppStorage("rcUserId") private var rcUserID: String = ""

    init() {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_nzoxZjFOdCffwvTEKrdMdDqjfzO")
        Purchases.shared.attribution.collectDeviceIdentifiers()

        Task {
            await self.checkSubscriptionStatus()
            Purchases.shared.attribution.collectDeviceIdentifiers()
            
        }
        
        rcUserID = Purchases.shared.appUserID
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
}
