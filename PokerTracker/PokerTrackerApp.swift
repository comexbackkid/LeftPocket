//
//  PokerTrackerApp.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

//let dictionary = Dictionary(grouping: MockData.allSessions, by: { $0.date })

@main
struct PokerTrackerApp: App {
    
    @StateObject var sessionsListViewModel: SessionsListViewModel = SessionsListViewModel()
    
    var body: some Scene {
        WindowGroup {
            PokerTrackerTabView().environmentObject(sessionsListViewModel)
        }
        
    }
}
