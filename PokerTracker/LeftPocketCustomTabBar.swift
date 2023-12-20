//
//  LeftPocketCustomTabBar.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/12/23.
//

import SwiftUI

struct LeftPocketCustomTabBar: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    
    @State var selectedTab = 0
    @State var isPresented = false
    
    let tabBarImages = ["house.fill", "list.bullet", "plus", "chart.bar.fill", "gearshape.fill"]
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                switch selectedTab {
                case 0:
                    ContentView()
                    
                case 1:
                    SessionsListView()
                    
                case 2:
                    Text("")
                    
                case 3:
                    MetricsView()
                    
                case 4:
                    UserSettings(isDarkMode: $isDarkMode, systemThemeEnabled: $systemThemeEnabled)
                
                default:
                    Text("Screen")
                }
            }
            
            VStack {
                
                Spacer()
                
                tabBar
            }
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
        .onAppear {
            shouldShowOnboarding = true
            SystemThemeManager
                .shared
                .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
        }
        .fullScreenCover(isPresented: $shouldShowOnboarding, content: {
            SignInTest(shouldShowOnboarding: $shouldShowOnboarding)
        })
    }
    
    var tabBar: some View {
        HStack {
            ForEach(0..<5) { index in
                Button {
            
                    if index == 2 {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        isPresented.toggle()
                        return
                    }
                    
                    selectedTab = index
                    
                } label: {
                    
                    Spacer()
                    
                    Image(systemName: tabBarImages[index])
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray4) )
                    
                    Spacer()
                }
                .sheet(isPresented: $isPresented) {
                    AddNewSessionView(isPresented: $isPresented)
                }
            }
        }
        .padding(.top)
        .background(.thickMaterial)
    }
}

struct LeftPocketCustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        LeftPocketCustomTabBar().environmentObject(SessionsListViewModel())
//            .preferredColorScheme(.dark)
    }
}
