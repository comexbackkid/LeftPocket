//
//  SubscriptionManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/22/23.
//

import Foundation
import RevenueCat
import SwiftUI

class SubscriptionManager: ObservableObject {

    @Published var isSubscribed = false

    init() {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_nzoxZjFOdCffwvTEKrdMdDqjfzO")

        Task {
            await self.checkSubscriptionStatus()
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
}
