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
                
                if #available(iOS 17.0, *) {
                    let addSessionTip = AddSessionTip()
                    
                    TipView(addSessionTip, arrowEdge: .bottom)
                        .tipViewStyle(CustomTipViewStyle())
                        .padding(.horizontal, 20)
                }
                
                if isCounting {
                    LiveSessionCounter()
                }
                
                tabBar
            }
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .onAppear {
            
            // Handles matching the user's iPhone system display settings
            SystemThemeManager
                .shared
                .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
            
            // If user has been using the app, we tell the Tips they are not a new user
            if #available(iOS 17.0, *) {
                AddSessionTip.newUser = viewModel.sessions.count > 0 ? false : true
            }
        }
    }
    
    var tabBar: some View {
        
        HStack {
            
            ForEach(0..<5) { index in
                
                if index != 2 {
                    
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        selectedTab = index
                        
                    } label: {
                        
                        Spacer()
                        
                        let tabBarImages = ["house.fill", "list.bullet", "plus", "chart.bar.fill", "gearshape.fill"]
                        
                        Image(systemName: tabBarImages[index])
                            .font(.system(size: index == 2 ? 30 : 22, weight: .black))
                            .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray3))
                        
                        Spacer()
                    }
                    
                } else {
                    
                    // Using a Menu here because the Context Menu style effect works cleaner & has smoother animation
                    Menu {

                        if !isCounting {
                            Button {
                                let impact = UIImpactFeedbackGenerator(style: .soft)
                                impact.impactOccurred()
                                
                                Task {
                                    if #available(iOS 17.0, *) {
                                        await AddSessionTip.sessionCount.donate()
                                    }
                                }
                                
                                // If user is NOT subscribed, AND they're over the monthly allowance, the Plus button will display Paywall
                                if !subManager.isSubscribed && !viewModel.canLogNewSession() {
                                    
                                    showPaywall = true
                                    
                                } else {
                                    
                                    isPresented = true
                                }
                                
                                return
                                
                            } label: {
                                Text("Add Completed Session")
                                Image(systemName: "calendar")
                            }
                            
                            Button {
                                
                                let impact = UIImpactFeedbackGenerator(style: .soft)
                                impact.impactOccurred()
                                
                                // If user is NOT subscribed, AND they're over the monthly allowance, the Plus button will display Paywall
                                if !subManager.isSubscribed && !viewModel.canLogNewSession() {
                                    
                                    showPaywall = true
                                    
                                } else {
                                    
                                    timerViewModel.startSession()
                                    isCounting = true
                                }
                                
                            } label: {
                                
                                Text("Start a Live Session")
                                Image(systemName: "timer")
                            }
                        }

                    } label: {
                        
                        Spacer()
                        
                        Image(systemName: isCounting ? "stop.fill" : "plus")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray3))
                        
                        Spacer()
                        
                    } primaryAction: {
                        
                        // Primary action is ALWAYS to bring up the Add New Session sheet, even if counting
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        Task {
                            if #available(iOS 17.0, *) {
                                await AddSessionTip.sessionCount.donate()
                            }
                        }
                        
                        // If user is NOT subscribed, AND they're over the monthly allowance, the Plus button will display Paywall
                        if !subManager.isSubscribed && !viewModel.canLogNewSession() {
                            
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
                            .dynamicTypeSize(.medium...DynamicTypeSize.large)
                            .overlay {
                                HStack {
                                    Spacer()
                                    VStack {
                                        DismissButton()
                                            .padding()
                                            .onTapGesture {
                                                showPaywall = false
                                        }
                                        Spacer()
                                    }
                                }
                            }
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
