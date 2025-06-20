//
//  OnboardingView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/18/21.
//

import SwiftUI
import RevenueCatUI
import RevenueCat
import AVKit
import UserNotifications

struct OnboardingView: View {
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var hkManager: HealthKitManager
    @Environment(\.dismiss) var dismiss
    @Binding var shouldShowOnboarding: Bool
    @State private var selectedPage: Int = 0
    @State private var shouldShowLastChance = false
    @State private var lastChanceOffer: Offering?
    @State private var paywallOffering: Offering?
    private let players: [String: AVPlayer] = [
        "import-sessions": AVPlayer(url: Bundle.main.url(forResource: "import-sessions", withExtension: "mp4")!),
        "metrics-screen": AVPlayer(url: Bundle.main.url(forResource: "metrics-screen", withExtension: "mp4")!),
        "health-metrics": AVPlayer(url: Bundle.main.url(forResource: "health-metrics", withExtension: "mp4")!)
    ]
    private var isZoomed: Bool { UIScreen.main.scale < UIScreen.main.nativeScale }
    var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    var body: some View {
        
        TabView(selection: $selectedPage) {
            
            WelcomeScreen(selectedPage: $selectedPage).gesture(DragGesture()).tag(0)
            
            PollView(showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(1)
            
            StartingBankroll(showDismissButton: false,
                             nextAction: nextPage,
                             shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(2)
            
            RiskTolerance(showDismissButton: false,
                        nextAction: nextPage,
                        shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(3)
            
            AllowNotifications(showDismissButton: false,
                               nextAction: nextPage,
                               shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(4)
            
            PageView(title: "Painless Data Imports",
                     subtitle: Text("From the Settings \(Image(systemName: "gearshape.fill")) screen importing old data from other apps is super easy. You can be up and running in a matter of seconds."),
                     videoURL: "import-sessions",
                     showDismissButton: false, player: players["import-sessions"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(5)
            
            PageView(title: "Say Bye to Low Stakes",
                     subtitle: Text("Insightful charts, progress rings, and crucial player metrics will advise when it's safe to take a shot at higher stakes."),
                     videoURL: "metrics-screen",
                     showDismissButton: false, player: players["metrics-screen"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(6)
            
            PageView(title: "Boost Your Mental Game",
                     subtitle: Text("Left Pocket requests access to your health info. This allows us to display your sleep hours, mindful minutes, and mood in our Health Analytics section, integrating numbers measured by other devices and apps. Your data is private and secure."),
                     videoURL: "health-metrics",
                     showDismissButton: true, player: players["health-metrics"],
                     skipAction: { fetchCurrentOffer() },
                     nextAction: { hkManager.requestAuthorization() },
                     shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(7)
        }
        .ignoresSafeArea()
        .dynamicTypeSize(...DynamicTypeSize.large)
        .onBoardingBackgroundStyle(colorScheme: .light)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: hkManager.authorizationStatus, perform: { state in
            if state != .notDetermined {
                fetchCurrentOffer()
                
            } else {
                fetchCurrentOffer()
            }
        })
        .fullScreenCover(item: $paywallOffering, onDismiss: {
            shouldShowOnboarding = false
        }, content: { offering in
            if isPad {
                if #available(iOS 18.0, *) {
                    PaywallView(offering: offering)
                        .dynamicTypeSize(.large)
                        .presentationSizing(.page)
                        .overlay {
                            HStack {
                                Spacer()
                                VStack {
                                    DismissButton()
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            self.paywallOffering = nil
                                    }
                                    Spacer()
                                }
                            }
                        }
                    
                } else {
                    PaywallView(offering: offering)
                        .dynamicTypeSize(.large)
                        .overlay {
                            HStack {
                                Spacer()
                                VStack {
                                    DismissButton()
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            self.paywallOffering = nil
                                    }
                                    Spacer()
                                }
                            }
                        }
                }
                
            } else {
                PaywallView(offering: offering)
                    .dynamicTypeSize(.large)
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                DismissButton()
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        self.paywallOffering = nil
                                }
                                Spacer()
                            }
                        }
                    }
            }
        })
        .task {
            await subManager.checkSubscriptionStatus()
        }
//        .task {
//            for await customerInfo in Purchases.shared.customerInfoStream {
//                let isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
//                
//                /// If at any point they subscribe, dismiss any and all paywalls, kill the onboarding flow, and proceed to the app
//                /// This is actually causing the onboarding to dismiss if the user redeems an offer outside the app
//                if isSubscribed {
//                    showPaywall = false
//                    lastChanceOffer = nil
//                    shouldShowOnboarding = false
//                }
//                
//                await subManager.checkSubscriptionStatus()
//            }
//        }
    }
    
    func nextPage() {
        withAnimation {
            selectedPage += 1
        }
    }
    
    func skipToLastPage() {
        withAnimation {
            selectedPage = 8
        }
    }
    
    private func fetchCurrentOffer() {
        if subManager.isSubscribed {
            shouldShowOnboarding = false
            
        } else {
            Task {
                do {
                    self.paywallOffering = try await Purchases.shared.offerings().current
                    
                } catch {
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
    /// This grabs our LastChanceOffer and when the offer is fetched, the paywall appears
//    @MainActor
//    private func fetchLastChanceOffer() async {
//        do {
//            lastChanceOffer = try await Purchases.shared.offerings().offering(identifier: "Last Chance Offer")
//            shouldShowLastChance = (lastChanceOffer != nil)
//
//        } catch {
//            print("ERROR fetching offering:", error)
//            shouldShowLastChance = false
//            shouldShowOnboarding = false
//        }
//    }
}

struct PageView: View {
    
    let title: String
    let subtitle: Text
    let videoURL: String
    let showDismissButton: Bool
    let player: AVPlayer?
    let skipAction: (() -> Void)?
    var nextAction: () -> Void
    
    @Binding var shouldShowOnboarding: Bool
    private var isZoomed: Bool { UIScreen.main.scale < UIScreen.main.nativeScale }
    var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    init(title: String,
         subtitle: Text,
         videoURL: String,
         showDismissButton: Bool,
         player: AVPlayer? = nil,
         skipAction: (() -> Void)? = nil,
         nextAction: @escaping () -> Void,
         shouldShowOnboarding: Binding<Bool>) {
        
        self.title = title
        self.subtitle = subtitle
        self.videoURL = videoURL
        self.showDismissButton = showDismissButton
        self.player = player
        self.skipAction = skipAction
        self.nextAction = nextAction
        self._shouldShowOnboarding = shouldShowOnboarding
    }
    
    var body: some View {
        
        VStack {
            
            video
            
            Text(title)
                .signInTitleStyle()
                .foregroundColor(.brandWhite)
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
                
            subtitle
                .calloutStyle()
                .lineSpacing(2.5)
                .opacity(0.7)
                .foregroundColor(.brandWhite)
                .padding(.horizontal, isPad ? 80 : 30)
            
            Spacer()
            
            if let skip = skipAction {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    skip()
                    
                } label: {
                    Text("No, thank you")
                        .subHeadlineStyle()
                        .buttonStyle(.plain)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
            }
            
            nextButton
        }
    }
    
    var video: some View {
        
        Group {
            if let player = player {
                
                if isPad {
                    VideoPlayer(player: player)
                        .frame(width: 480, height: 480)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.vertical, 30)
                        .onAppear {
                            player.seek(to: .zero)
                            player.play()
                        }
                        .onDisappear {
                            player.pause()
                        }
                    
                } else {
                    VideoPlayer(player: player)
                        .frame(width: isZoomed ? 240 : 340, height: isZoomed ? 240 : 340)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.vertical, 30)
                        .onAppear {
                            player.seek(to: .zero)
                            player.play()
                        }
                        .onDisappear {
                            player.pause()
                        }
                }
                
            } else {
                Text("Error. Video file not found.")
                    .bodyStyle()
                    .padding()
            }
        }
    }
    
    var nextButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            nextAction()
            
        } label: {
            Text(showDismissButton ? "Let's Do It" : "Continue")
                .buttonTextStyle()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.white)
                .cornerRadius(30)
                .padding(.horizontal, isPad ? 50 : 30)
                .padding(.bottom, 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shouldShowOnboarding: .constant(true))
            .environmentObject(SubscriptionManager())
            .environmentObject(HealthKitManager())
            .preferredColorScheme(.dark)
    }
}
