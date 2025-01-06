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
import AVKit
import UserNotifications
import NotificationCenter

struct LeftPocketCustomTabBar: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
    @AppStorage("pushNotificationsAllowed") private var notificationsAllowed: Bool?
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var qaService: QAService
    @Environment(\.scenePhase) var scenePhase
    @StateObject var timerViewModel = TimerViewModel()
    
    @State var selectedTab = 0
    @State var isPresented = false
    @State var showPaywall = false
    @State var showNewTransaction = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioConfirmation = false
    @State private var showAlert = false
    @State private var showBuyInScreen = false
    @State private var activity: Activity<LiveSessionWidgetAttributes>?
    @State private var buyInConfirmationSound = false
    @State private var showSessionDefaultsView = false
    
    var isCounting: Bool {
        timerViewModel.isCounting
    }
    
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
                    MetricsView(activeSheet: .constant(nil))
                    
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
                
                if viewModel.sessions.count == 3 || viewModel.sessions.count > 6 {
                    if #available(iOS 17.0, *) {
                        let settingsTip = SettingsTip()
                        
                        TipView(settingsTip)
                            .tipViewStyle(CustomTipViewStyle())
                            .padding(.horizontal, 20)
                    }
                }
                
                if isCounting {
                    LiveSessionCounter(timerViewModel: timerViewModel)
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
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus != .authorized {
                    notificationsAllowed = false
                }
            }
            
            NotificationCenter.default.addObserver(forName: .openMetricsView, object: nil, queue: .main) { _ in
                selectedTab = 3
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .openMetricsView, object: nil)
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
                        
                        let tabBarImages = ["house.fill", "list.bullet", "cross.fill", "chart.bar.fill", "gearshape.fill"]
                        
                        Image(systemName: tabBarImages[index])
                            .font(.system(size: index == 2 ? 28 : 22, weight: .black))
                            .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray3))
                        
                        Spacer()
                    }
                    
                } else if !isCounting {
                    
                    // This is why this is structured using a Menu, and how it works.
                    // The Menu functionality provides the clean, one-click look that doesn't distort the button like a Context Menu
                    // Now, if there's no live session going on (isCounting), Tab bar displays the standard Plus button that brings up the options
                    // Below, the rendered Tab Bar view will show a stop button IF it detects that there's a live session in progress
                    
                    Menu {

                        if !isCounting {
                            
                            // MARK: Add Completed Session Button
                            
                            Button {
                                logCompletedSession()
                                
                            } label: {
                                Text("Add Completed Session")
                                Image(systemName: "calendar")
                            }
                            
                            // MARK: Start Live Session Button
                            
                            Button {
                                startLiveSession()
                                
                            } label: {
                                Text("Start a Live Session")
                                Image(systemName: "timer")
                            }
                            
                            Divider()
                            
                            Button {
                                let impact = UIImpactFeedbackGenerator(style: .soft)
                                impact.impactOccurred()
                                showNewTransaction = true
                                
                            } label: {
                                Text("Enter Transaction")
                                Image(systemName: "creditcard.fill")
                            }
                        }

                    } label: {
                        
                        Spacer()
                        Image(systemName: isCounting ? "stop.fill" : "cross.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color(.systemGray3))
                        Spacer()
                        
                    }
                    .sheet(isPresented: $showNewTransaction, onDismiss: { 
                        if audioConfirmation {
                            playSound()
                        }
                     }, content: {
                        AddNewTransaction(showNewTransaction: $showNewTransaction, audioConfirmation: $audioConfirmation)
                    })
                    .onTapGesture(perform: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    })
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
                    
                } else {
                    
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                        impact.impactOccurred()
                        showAlert = true
                        
                    } label: {
                        
                        Spacer()
                        Image(systemName: "stop.fill")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(Color(.systemGray3))
                        Spacer()
                        
                    }
                    .alert(Text("Are You Sure?"), isPresented: $showAlert) {
                        
                        Button("Yes", role: .destructive) {
                            timerViewModel.stopTimer()
                            LiveActivityManager().endActivity()
                            isPresented = true
                        }
                        
                        Button("Cancel", role: .cancel) {
                            print("User is resuming Live Session")
                        }
                    } message: {
                        Text("If you're ready to end your Live Session, tap Yes & then input Session details on the next screen.")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
        .background(.thickMaterial)
        .sheet(isPresented: $isPresented, onDismiss: {
            timerViewModel.resetTimer()
            if audioConfirmation {
                playSound()
            }
        }, content: {
            AddNewSessionView(timerViewModel: timerViewModel, isPresented: $isPresented, audioConfirmation: $audioConfirmation)
        })
        .onChange(of: qaService.action) { _ in
            performQuickAction()
        }
        .sheet(isPresented: $showBuyInScreen, onDismiss: {
            if buyInConfirmationSound {
                playBuyInCashSound()
            }
        }, content: {
            LiveSessionInitialBuyIn(timerViewModel: timerViewModel, buyInConfirmationSound: $buyInConfirmationSound)
                .presentationDetents([.height(350), .large])
                .presentationBackground(.ultraThinMaterial)
                .interactiveDismissDisabled()
        })
        .sheet(isPresented: $showSessionDefaultsView) {
            SessionDefaultsView(isPresentedAsSheet: .constant(true))
        }
    }
    
    func playSound() {
            
        guard let url = Bundle.main.url(forResource: "cash-sfx", withExtension: ".wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error loading sound: \(error.localizedDescription)")
        }
    }
    
    func playBuyInCashSound() {
        guard let url = Bundle.main.url(forResource: "rebuy-sfx", withExtension: ".wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error loading sound: \(error.localizedDescription)")
        }
    }
    
    func startLiveSession() {
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
            
            if notificationsAllowed != true {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                    if success {
                        notificationsAllowed = true
                    } else if let error {
                        print("There was an error: \(error.localizedDescription)")
                    }
                }
            }
            
            timerViewModel.startSession()
            activity = LiveActivityManager().startActivity(startTime: Date(), elapsedTime: timerViewModel.liveSessionTimer)
            showBuyInScreen = true
        }
    }
    
    func logCompletedSession() {
        
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
    }
    
    func performQuickAction() {
        guard let action = qaService.action else { return }
        
        if isCounting && action == .addNewSession || action == .enterTransaction {
            // Optionally show an alert or log a message instead of performing the action
            print("Cannot add a new session while a live session is active.")
            qaService.action = nil
            return
        }
        
        switch action {
        case .addNewSession: isPresented = true
        case .enterTransaction: showNewTransaction = true
        case .viewAllSessions: selectedTab = 1
        }
        
        qaService.action = nil
    }
}

struct LeftPocketCustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        LeftPocketCustomTabBar()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(QAService())
            .preferredColorScheme(.dark)
    }
}
