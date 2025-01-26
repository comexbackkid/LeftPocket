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

@main
struct LeftPocketApp: App {
    
    @StateObject var hkManager = HealthKitManager()
    @StateObject var vm = SessionsListViewModel()
    @StateObject var subManager = SubscriptionManager()
    @AppStorage("shouldShowOnboarding") var showWelcomeScreen: Bool = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    private let qaService = QAService.shared

    var body: some Scene {
        WindowGroup {
            LeftPocketCustomTabBar()
                .fullScreenCover(isPresented: $showWelcomeScreen, content: {
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
    }
    
    func configureTips() {
//        try? Tips.resetDatastore()
        try? Tips.configure([.datastoreLocation(TipKitConfig.storeLocation),
                             .displayFrequency(TipKitConfig.displayFrequency)])
    }
    
    // MARK: MIGRATION CODE
    
    
    // TODO: Use a check to see if the new sessions_v2.json exists, instead of a Bool
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
