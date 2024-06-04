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
    
    @StateObject var vm = SessionsListViewModel()
    @StateObject var subManager = SubscriptionManager()
    @StateObject private var timerViewModel = TimerViewModel()
    @AppStorage("shouldShowOnboarding") var showWelcomeScreen: Bool = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            LeftPocketCustomTabBar()
                .fullScreenCover(isPresented: $showWelcomeScreen, content: {
                    OnboardingView(shouldShowOnboarding: $showWelcomeScreen)
                })
                .environmentObject(vm)
                .environmentObject(subManager)
                .environmentObject(timerViewModel)
                .onOpenURL(perform: { url in
                    Branch.getInstance().handleDeepLink(url)
                })
        }
    }
    
    init() {
        configureTips()
    }
    
    
    func configureTips() {
        if #available(iOS 17.0, *) {
//            try? Tips.resetDatastore()
            try? Tips.configure([.datastoreLocation(TipKitConfig.storeLocation),
                                 .displayFrequency(TipKitConfig.displayFrequency)])
        }
    }
}
