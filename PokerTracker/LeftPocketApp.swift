//
//  PokerTrackerApp.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import TipKit

@main
struct LeftPocketApp: App {
    
    @StateObject var vm = SessionsListViewModel()
    @StateObject var subManager = SubscriptionManager()
    @StateObject private var timerViewModel = TimerViewModel()
    @AppStorage("shouldShowOnboarding") var showWelcomeScreen: Bool = true

    var body: some Scene {
        WindowGroup {
            LeftPocketCustomTabBar()
                .fullScreenCover(isPresented: $showWelcomeScreen, content: {
                    WelcomeScreen(showWelcomeScreen: $showWelcomeScreen)
                })
                .environmentObject(vm)
                .environmentObject(subManager)
                .environmentObject(timerViewModel)
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
