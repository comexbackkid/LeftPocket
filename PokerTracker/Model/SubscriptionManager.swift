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
import UserNotifications

class SubscriptionManager: NSObject, ObservableObject, PurchasesDelegate {
    
    @Published var isSubscribed = false
    @AppStorage("rcUserId") private var rcUserID: String = ""
    
    override init() {
        super.init()
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_nzoxZjFOdCffwvTEKrdMdDqjfzO")
        Purchases.shared.delegate = self
        Purchases.shared.attribution.collectDeviceIdentifiers()
        
        let appUserID = Purchases.shared.appUserID
        if appUserID.isEmpty {
            print("RevenueCat appUserID is empty, generating anonymous ID")
            
        } else {
            rcUserID = appUserID
            print("Your RevenueCat UserID is: \(rcUserID)")
        }
        
        Task {
            await self.checkSubscriptionStatus()
            Purchases.shared.attribution.collectDeviceIdentifiers()
        }
    }
    
    @MainActor
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if let isActive = customerInfo.entitlements["premium"]?.isActive {
                self.isSubscribed = isActive
                
            } else {
                print("Premium entitlement missing or nil")
            }
            
        } catch {
            print("Problem checking subscription status: \(error.localizedDescription)")
        }
    }
    
    // Check if the user is currently enrolled in a free trial so we can remind them about cancellation
    func checkTrialStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if let premiumEntitlement = customerInfo.entitlements["premium"] {
                if premiumEntitlement.periodType == .trial {
                    if let trialEndDate = premiumEntitlement.expirationDate {
                        scheduleTrialExpirationNotification(expirationDate: trialEndDate)
                        print("User's free trial end date is: \(trialEndDate)")
                    }
                    
                } else {
                    print("ERROR: Can't determine if user is in a free trial.")
                }
            }
            
        } catch {
            print("ERROR: Problem checking customer entitlement info for trial status.")
        }
    }
    
    // Notification reminder for free trial end date
    func scheduleTrialExpirationNotification(expirationDate: Date) {
        /// Left Pocket Pro $9.99/mo is 7 Day Free Trial
        /// Left Pocket Pro $79.99/year is 14 Day Free Trial
        /// Left Pocket Pro $2.99/wk is 3 Day Free Trial
        let daysBeforeNotification = 2
        let notificationTime = expirationDate.addingTimeInterval(TimeInterval(-daysBeforeNotification * 24 * 60 * 60))
        
        let content = UNMutableNotificationContent()
        content.title = "Free Trial Ending Soon"
        content.body = "This is a reminder that you still have \(daysBeforeNotification) days until your trial ends."
        content.sound = UNNotificationSound.default
        
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "trialExpirationNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Trial expiration push notification scheduled for \(notificationTime)")
            }
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
