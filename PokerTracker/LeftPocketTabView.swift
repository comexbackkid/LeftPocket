//
//  PokerTrackerTabView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/25/21.
//

//import SwiftUI
//
//struct LeftPocketTabView: View {
//    
//    @AppStorage("isDarkMode") private var isDarkMode = false
//    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
//    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
//    
//    var body: some View {
//        
//        TabView {
//            ContentView()
//                .tabItem {
//                    Image(systemName: "house.fill")
//                }
//            
//            SessionsListView()
//                .tabItem {
//                    Image(systemName: "list.bullet")
//                }
//            
//            MetricsView()
//                .tabItem {
//                    Image(systemName: "chart.bar.fill")
//                }
//            
//            StudyView()
//                .tabItem {
//                    Image(systemName: "text.book.closed.fill")
//                }
//            
//            UserSettings(isDarkMode: $isDarkMode, systemThemeEnabled: $systemThemeEnabled)
//                .tabItem {
//                    Image(systemName: "gearshape.fill")
//                }
//        }
//        .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
//        .accentColor(.brandPrimary)
//        .fullScreenCover(isPresented: $shouldShowOnboarding, content: {
//            OnboardingView(shouldShowOnboarding: $shouldShowOnboarding)
//        })
//        .onAppear {
//            SystemThemeManager
//                .shared
//                .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
//        }
//    }
//}
//
//struct LeftPocketTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftPocketTabView().environmentObject(SessionsListViewModel())
//    }
//}
