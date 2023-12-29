//
//  SubscriptionManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/22/23.
//

import Foundation
import RevenueCat
import SwiftUI

// MARK: Original

//class SubscriptionManager: NSObject, ObservableObject, PurchasesDelegate {
//
//    @Published var isSubscribed = false
//
//    override init() {
//
//        super.init()
//        Purchases.logLevel = .debug
//        Purchases.configure(withAPIKey: "appl_nzoxZjFOdCffwvTEKrdMdDqjfzO")
//        Purchases.shared.delegate = self
//
//        Task { @MainActor in
//            await self.checkSubscriptionStatus()
//        }
//    }
//
//    @MainActor func checkSubscriptionStatus() async {
//
//        do {
//            let customerInfo = try await Purchases.shared.customerInfo()
//            self.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
//
//        } catch {
//            print("Problem checking subscription status: \(error)")
//        }
//    }
//
//    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
//            // handle any changes to customerInfo
//        Task { await checkSubscriptionStatus() }
//        print("We wuz subscribed")
//    }
//}

// MARK: MY IDIOT VERSION OF THE SUBSCRIPTION MANAGER

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
