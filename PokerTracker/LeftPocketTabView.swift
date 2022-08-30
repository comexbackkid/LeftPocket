//
//  PokerTrackerTabView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/25/21.
//

import SwiftUI

struct LeftPocketTabView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    
    var body: some View {
        
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SessionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Sessions")
                }
            
            MetricsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Metrics")
                }
            
            StudyView()
                .tabItem {
                    Image(systemName: "text.book.closed.fill")
                    Text("Study")
                }
            
            SettingsView(isDarkMode: $isDarkMode, systemThemeEnabled: $systemThemeEnabled)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .accentColor(.brandPrimary)
        .fullScreenCover(isPresented: $shouldShowOnboarding, content: {
            OnboardingView(shouldShowOnboarding: $shouldShowOnboarding)
        })
        .onAppear {
            SystemThemeManager
                .shared
                .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
            
            // Disables auto-transparent behavior in new update
//            let appearance = UITabBarAppearance()
//            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct LeftPocketTabView_Previews: PreviewProvider {
    static var previews: some View {
        LeftPocketTabView().environmentObject(SessionsListViewModel())
    }
}
