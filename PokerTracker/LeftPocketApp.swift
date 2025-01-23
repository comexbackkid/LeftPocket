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
}
