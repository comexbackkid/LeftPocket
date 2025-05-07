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
import Lottie

struct LeftPocketCustomTabBar: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
    @AppStorage("pushNotificationsAllowed") private var notificationsAllowed: Bool?
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var qaService: QAService
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @StateObject var timerViewModel = TimerViewModel()
    @State var selectedTab = 0
    @State var isPresented = false
    @State var showPaywall = false
    @State var showNewTransaction = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioConfirmation = false
    @State private var showAlert = false
    @State private var showFirstSessionSuccessModal = false
    @State private var showBuyInScreen = false
    @State private var activity: Activity<LiveSessionWidgetAttributes>?
    @State private var buyInConfirmationSound = false
    @State private var showSessionDefaultsView = false
    @State private var playbackMode = LottiePlaybackMode.paused(at: .progress(0))
    @State private var isAnimating = false
    
    let addSessionTip = AddSessionTip()
    var isCounting: Bool { true
//        withAnimation {
//            timerViewModel.isCounting
//        }
    }
    var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    var body: some View {
        
        ZStack {
            
            VStack {
                switch selectedTab {
                case 0: ContentView()
                case 1: SessionsListView()
                case 2: Text("")
                case 3: MetricsView(activeSheet: .constant(nil))
                case 4: UserSettings(isDarkMode: $isDarkMode, systemThemeEnabled: $systemThemeEnabled)
                default: Text("")
                }
            }
            
            VStack {
                
                Spacer()
                                
                tips
                
//                ZStack {
//                    LiveSessionCounter(timerViewModel: timerViewModel)
//                        .offset(y: isCounting ? 0 : 200)
//                        .opacity(isCounting ? 1 : 0)
//                        .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: isCounting)
//                }
                
                tabBar
            }
        }
        .overlay {
            if isAnimating {
                VStack {
                    LottieView(animation: .named("Lottie-Confetti-Congrats"))
                        .playbackMode(playbackMode)
                        .animationDidFinish { _ in
                            playbackMode = .paused(at: .progress(0))
                            isAnimating = false
                        }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .onAppear {
            // Handles matching the user's iPhone system display settings
            SystemThemeManager
                .shared
                .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
            
            // If user has been using the app, we tell the Tips they are not a new user
            AddSessionTip.newUser = viewModel.sessions.count > 0 ? false : true

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
        .sheet(isPresented: $showFirstSessionSuccessModal) {
            FirstSessionCompleteModal(message: "First session in the books! Consider sharing your progress with friends – accountability increases our chance of success by 65%!", image: "trophy", imageColor: .yellow)
                .presentationDragIndicator(.visible)
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                .presentationDetents([.height(360)])
                .onAppear {
                    playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
                    isAnimating = true
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
                        tabButton(for: index)
                    }
                    
                } else if !isCounting {
                    plusMenuButton
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        }
                        .fullScreenCover(isPresented: $showPaywall, content: {
                            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                                .dynamicTypeSize(.large)
                                .overlay {
                                    HStack {
                                        Spacer()
                                        VStack {
                                            DismissButton()
                                                .padding(.horizontal)
                                                .onTapGesture {
                                                    showPaywall = false
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                        })
                        .task {
                            for await customerInfo in Purchases.shared.customerInfoStream {
                                
                                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                                await subManager.checkSubscriptionStatus()
                            }
                        }
                    
                } else {
                    stopLiveSessionButton
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
        .background(.thickMaterial)
        .onChange(of: viewModel.allSessions.count) { oldValue, newValue in
            if oldValue == 0 && newValue == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    showFirstSessionSuccessModal = true
                }
            }
        }
        .sheet(isPresented: $isPresented, onDismiss: {
            timerViewModel.resetTimer()
            if audioConfirmation {
                playSound()
            }
        }, content: {
            if isPad {
                if #available(iOS 18.0, *) {
                    AddNewSessionView(timerViewModel: timerViewModel, audioConfirmation: $audioConfirmation)
                        .presentationSizing(.page)
                } else {
                    AddNewSessionView(timerViewModel: timerViewModel, audioConfirmation: $audioConfirmation)
                }
            } else {
                AddNewSessionView(timerViewModel: timerViewModel, audioConfirmation: $audioConfirmation)
                    .presentationDragIndicator(.visible)
            }
        })
        .onChange(of: qaService.action) { _ in
            performQuickAction()
        }
        
        .sheet(isPresented: $showBuyInScreen, onDismiss: {
            timerViewModel.startSession()
            LiveActivityManager.shared.startActivity(startTime: Date(), elapsedTime: timerViewModel.liveSessionTimer)
            if buyInConfirmationSound {
                playBuyInCashSound()
            }
        }, content: {
            LiveSessionInitialBuyIn(timerViewModel: timerViewModel, buyInConfirmationSound: $buyInConfirmationSound)
                .presentationDetents([.height(400), .large])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                .interactiveDismissDisabled()
        })
        .sheet(isPresented: $showSessionDefaultsView) {
            SessionDefaultsView(isPresentedAsSheet: .constant(true))
        }
    }
    
    var tips: some View {
        
        VStack {
            
            TipView(addSessionTip, arrowEdge: .bottom)
                .tipViewStyle(CustomTipViewStyle())
                .padding(.horizontal, 20)
            
            if viewModel.sessions.count == 3 {
                
                let settingsTip = SettingsTip()
                TipView(settingsTip)
                    .tipViewStyle(CustomTipViewStyle())
                    .padding(.horizontal, 20)
            }
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
        addSessionTip.invalidate(reason: .actionPerformed)
        
        // If user is NOT subscribed, AND they're over the monthly allowance, the Plus button will display Paywall
        if !subManager.isSubscribed && !viewModel.canLogNewSession() {
            
            showPaywall = true
            
        } else {
            showBuyInScreen = true
        }
    }
    
    func logCompletedSession() {
        
        let impact = UIImpactFeedbackGenerator(style: .soft)
        impact.impactOccurred()
        addSessionTip.invalidate(reason: .actionPerformed)
        
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
        
        if isCounting && action == .addNewSession || isCounting && action == .enterTransaction {
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
    
    @ViewBuilder
    func tabButton(for index: Int) -> some View {
        Spacer()
        let tabBarImages = ["custom-house-icon", "list.bullet", "cross.fill", "chart.bar.fill", "gearshape.fill"]
        if index == 0 {
            Image("custom-house-icon")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray3))
            
        } else {
            Image(systemName: tabBarImages[index])
                .font(.system(size: index == 2 ? 28 : 22, weight: .medium))
                .foregroundColor(selectedTab == index ? .brandPrimary : Color(.systemGray3))
        }
        
        Spacer()
    }
    
    @ViewBuilder
    var plusMenuButton: some View {
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
                .presentationDragIndicator(.visible)
        })
    }
    
    @ViewBuilder
    var stopLiveSessionButton: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            showAlert = true
            
        } label: {
            Spacer()
            Image(systemName: "stop.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(Color(.systemGray3))
            Spacer()
            
        }
        .alert(Text("Are You Sure?"), isPresented: $showAlert) {
            
            Button("Yes", role: .destructive) {
                timerViewModel.stopTimer()
                LiveActivityManager.shared.endActivity()
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

struct LeftPocketCustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        LeftPocketCustomTabBar()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(QAService())
            .preferredColorScheme(.dark)
    }
}
