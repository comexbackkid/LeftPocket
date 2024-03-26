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
import ActivityKit

struct LeftPocketCustomTabBar: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
    @AppStorage("isCounting") private var isCounting = false
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    
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
                
                if isCounting {
                    LiveSessionCounter()
                }
                
                tabBarNew
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
    
    // TODO: Delete once fully test tabBarNew
//    var tabBar: some View {
//        
//        HStack {
//            ForEach(0..<5) { index in
//                
//                Button {
//            
//                    if index == 2 {
//                        let impact = UIImpactFeedbackGenerator(style: .medium)
//                        impact.impactOccurred()
//                        
//                        Task {
//                            await AddSessionTip.sessionCount.donate()
//                        }
//                        
//                        // If user is NOT subscribed, AND they reach the 25 Session limit, the Plus button will display Paywall
//                        if !subManager.isSubscribed && viewModel.sessions.count > 24 {
//                            
//                            showPaywall = true
//                        } else {
//                            
//                            isPresented = true
//                        }
//                        
//                        return
//                    }
//                    
//                    let impact = UIImpactFeedbackGenerator(style: .soft)
//                    impact.impactOccurred()
//                    
//                    selectedTab = index
//                    
//                } label: {
//                    
//                    Spacer()
//                    
//                    Image(systemName: tabBarImages[index])
//                        .font(.system(size: index == 2 ? 30 : 22, weight: .black))
//                        .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray4) )
//                    
//                    Spacer()
//                }
//                .sheet(isPresented: $showPaywall) {
//                    PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
//                        .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
//                }
//                .task {
//                    for await customerInfo in Purchases.shared.customerInfoStream {
//                        showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
//                        await subManager.checkSubscriptionStatus()
//                    }
//                }
//            }
//        }
//        .padding(.top)
//        .background(.thickMaterial)
//        .sheet(isPresented: $isPresented) {
//            AddNewSessionView(isPresented: $isPresented)
//        }
//    }
    
    var tabBarNew: some View {
        
        HStack {
            
            ForEach(0..<5) { index in
                
                // Draw a standard button as long as the index isn't the Add New Session image
                if index != 2 {
                    
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        selectedTab = index
                        
                    } label: {
                        
                        Spacer()
                        
                        Image(systemName: tabBarImages[index])
                            .font(.system(size: index == 2 ? 30 : 22, weight: .black))
                            .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray4))
                        
                        Spacer()
                    }
                    
                } else {
                    
                    // The Add New Session is actually a Menu with a button label
                    // This allows for a Context Menu style but without the buggy animations
                    Menu {

                        if !isCounting {
                            Button {
                                let impact = UIImpactFeedbackGenerator(style: .soft)
                                impact.impactOccurred()
                                
                                Task {
                                    await AddSessionTip.sessionCount.donate()
                                }
                                
                                // If user is NOT subscribed, AND they reach the 25 Session limit, the Plus button will display Paywall
                                if !subManager.isSubscribed && viewModel.sessions.count > 24 {
                                    showPaywall = true
                                    
                                } else { isPresented = true }
                                
                                return
                                
                            } label: {
                                Text("Add Completed Session")
                                Image(systemName: "calendar")
                            }
                            
                            Button {
                                
                                let impact = UIImpactFeedbackGenerator(style: .soft)
                                impact.impactOccurred()
                                
                                timerViewModel.startSession()
                                isCounting = true
                                
                            } label: {
                                
                                Text("Start a Live Session")
                                Image(systemName: "timer")
                            }
                        }

                    } label: {
                        
                        Spacer()
                        
                        Image(systemName: isCounting ? "stop.fill" : "plus")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray4))
                        
                        Spacer()
                        
                    } primaryAction: {
                        
                        // Primary action is ALWAYS to bring up the Add New Session sheet, even if counting
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        Task {
                            await AddSessionTip.sessionCount.donate()
                        }
                        
                        // If user is NOT subscribed, AND they reach the 25 Session limit, the Plus button will display Paywall
                        if !subManager.isSubscribed && viewModel.sessions.count > 24 {
                            
                            showPaywall = true
                            
                        } else {
                            
                            isCounting = false
                            timerViewModel.stopTimer()
                            isPresented = true
                        }
                        
                        return
                        
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
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
        .background(.thickMaterial)
        .sheet(isPresented: $isPresented, onDismiss: { timerViewModel.resetTimer() }) {
            AddNewSessionView(isPresented: $isPresented)
        }
    }
}

struct LeftPocketCustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        LeftPocketCustomTabBar()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(TimerViewModel())
            .preferredColorScheme(.dark)
    }
}
