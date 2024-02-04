//
//  PokerTrackerApp.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

@main
struct LeftPocketApp: App {
    
    @StateObject var vm = SessionsListViewModel()
    @StateObject var subManager = SubscriptionManager()
    @AppStorage("shouldShowOnboarding") var showWelcomeScreen: Bool = true

    var body: some Scene {
        WindowGroup {
            LeftPocketCustomTabBar()
                .fullScreenCover(isPresented: $showWelcomeScreen, content: {
                    SignInTest(showWelcomeScreen: $showWelcomeScreen)
                })
                .environmentObject(vm)
                .environmentObject(subManager)
        }
    }
}
