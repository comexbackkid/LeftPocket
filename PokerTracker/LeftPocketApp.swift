//
//  PokerTrackerApp.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import TipKit
import BranchSDK
import RevenueCat
import ActivityKit

@main
struct LeftPocketApp: App {
    
#if os(iOS)
    @StateObject var hkManager = HealthKitManager()
#endif
    @StateObject var vm = SessionsListViewModel()
    @StateObject var subManager = SubscriptionManager()
    @AppStorage("shouldShowOnboarding") var showWelcomeScreen: Bool = true
    @AppStorage("savedStartingBankroll") var savedStartingBankroll: String = ""
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    private let qaService = QAService.shared

    var body: some Scene {
        WindowGroup {
            LeftPocketCustomTabBar()
                .fullScreenCover(isPresented: $showWelcomeScreen, onDismiss: {
                    if !savedStartingBankroll.isEmpty {
                        let transaction = BankrollTransaction(date: Date(), type: .deposit, amount: Int(savedStartingBankroll) ?? 0, notes: "Starting Bankroll", tags: nil)
                        vm.transactions.append(transaction)
                    }
                }, content: {
                    OnboardingView(shouldShowOnboarding: $showWelcomeScreen)
                })
                .environmentObject(vm)
                .environmentObject(subManager)
                .environmentObject(hkManager)
                .environmentObject(qaService)
                .onOpenURL(perform: { url in
                    handleDeepLinkURL(url: url)
                    Branch.getInstance().handleDeepLink(url)
                })
                .onAppear {
                    migrateDataIfNeeded(viewModel: vm)
                }
        }
    }
        
    init() {
        configureTips()
        
        // This helps kill the stale Activity, but we aren't yet bothering to restart a new one, it glitches the app
        Task {
            let existingActivities = Activity<LiveSessionWidgetAttributes>.activities
            if !existingActivities.isEmpty {
                print("Found lingering Live Activities on launch. Ending them now.")
                for activity in existingActivities {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }
    }
    
    func configureTips() {
//        try? Tips.resetDatastore()
        try? Tips.configure([.datastoreLocation(TipKitConfig.storeLocation),
                             .displayFrequency(TipKitConfig.displayFrequency)])
    }
    
    func migrateDataIfNeeded(viewModel: SessionsListViewModel) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let newSessionsFile = documentsURL.appendingPathComponent("sessions_v2.json")
        
        // Check if the new sessions file already exists
        if fileManager.fileExists(atPath: newSessionsFile.path) {
            print("Migration not needed. sessions_v2.json already exists.")
            return
        }
        
        // Perform migration if sessions_v2.json does not exist
        print("Migration needed. Starting migration process...")
        let migratedLocations = MigrationHandler.migrateLocationModel()
        let migratedSessions = MigrationHandler.migratePokerSessionModel()
        
        // Update SessionsListViewModel
        if let locations = migratedLocations {
            viewModel.locations = locations
        }
        if let sessions = migratedSessions {
            viewModel.sessions = sessions
        }
        
        print("Migration of Locations & Sessions completed successfully.")
    }
}
