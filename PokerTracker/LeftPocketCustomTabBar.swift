//
//  LeftPocketCustomTabBar.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/12/23.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import TipKit

struct LeftPocketCustomTabBar: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State var selectedTab = 0
    @State var isPresented = false
    @State var showPaywall = false
    
    let tabBarImages = ["house.fill", "list.bullet", "plus", "chart.bar.fill", "gearshape.fill"]
    let addSessionTip = AddSessionTip()
    
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
                    Text("")
                }
            }
            
            VStack {
                
                Spacer()
                
                TipView(addSessionTip, arrowEdge: .bottom)
                    .padding(.horizontal)
                
                tabBar
            }
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
        .onAppear {
            
            // Handles matching the user's iPhone system display settings
            SystemThemeManager
                .shared
                .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
            
            // If user has been using the app, we tell the Tips they are not a new user
            AddSessionTip.newUser = viewModel.sessions.count > 0 ? false : true
        }
    }
    
    var tabBar: some View {
        
        HStack {
            ForEach(0..<5) { index in
                
                Button {
            
                    if index == 2 {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        Task {
                            await AddSessionTip.sessionCount.donate()
                        }
                        
                        // If user is NOT subscribed, AND they reach the 25 Session limit, the Plus button will display Paywall
                        if !subManager.isSubscribed && viewModel.sessions.count > 24 {
                            
                            showPaywall = true
                        } else {
                            
                            isPresented = true
                        }
                        
                        return
                    }
                    
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    
                    selectedTab = index
                    
                } label: {
                    
                    Spacer()
                    
                    Image(systemName: tabBarImages[index])
                        .font(.system(size: index == 2 ? 30 : 22, weight: .black))
                        .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray4) )
                    
                    Spacer()
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                        .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
                }
                .task {
                    for await customerInfo in Purchases.shared.customerInfoStream {
                        showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                        await subManager.checkSubscriptionStatus()
                    }
                }
            }
        }
        .padding(.top)
        .background(.thickMaterial)
        .sheet(isPresented: $isPresented) {
            AddNewSessionView(isPresented: $isPresented)
        }
    }
}

struct LeftPocketCustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        LeftPocketCustomTabBar()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
    }
}
