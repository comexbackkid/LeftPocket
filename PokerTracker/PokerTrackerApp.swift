//
//  PokerTrackerApp.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

@main
struct PokerTrackerApp: App {
    
    @StateObject var sessionsListViewModel: SessionsListModel = SessionsListModel()
    
    var body: some Scene {
        WindowGroup {
            PokerTrackerTabView().environmentObject(sessionsListViewModel)
        }
        
    }
}
