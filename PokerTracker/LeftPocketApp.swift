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

    var body: some Scene {
        WindowGroup {
            LeftPocketCustomTabBar()
                .environmentObject(vm)
                .environmentObject(subManager)
        }
    }
}
