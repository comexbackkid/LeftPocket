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
    @State private var showPaywall = false
    @State private var shouldShowLastChance = false
    @State private var offering: Offering?
    private let players: [String: AVPlayer] = [
        "import-sessions": AVPlayer(url: Bundle.main.url(forResource: "import-sessions", withExtension: "mp4")!),
        "metrics-screen": AVPlayer(url: Bundle.main.url(forResource: "metrics-screen", withExtension: "mp4")!),
        "health-metrics": AVPlayer(url: Bundle.main.url(forResource: "health-metrics", withExtension: "mp4")!)
    ]
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
    }
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
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
                     subtitle: Text("For an optimal experience, Left Pocket requests access to your Health info. This allows us to display your sleep hours and mindful minutes in our Health Analytics page, and integrate these numbers measured by other devices."),
                     videoURL: "health-metrics",
                     showDismissButton: true, player: players["health-metrics"],
                     nextAction: { hkManager.requestAuthorization() },
                     shouldShowOnboarding: $shouldShowOnboarding).contentShape(Rectangle()).gesture(DragGesture()).tag(7)
        }
        .ignoresSafeArea()
        .dynamicTypeSize(...DynamicTypeSize.large)
        .onBoardingBackgroundStyle(colorScheme: .light)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: hkManager.authorizationStatus, perform: { state in
            if state != .notDetermined {
                showPaywall = true
            } else {
                showPaywall = true
            }
        })
        .fullScreenCover(isPresented: $showPaywall, onDismiss: {
            /// After first paywall is closed, check the subscription status. If they didn't subscribe, hit user with Last Chance Offer
            Task {
                if !subManager.isSubscribed {
                    lastChanceOfferFetch()
                    
                } else {
                    /// If they did subscribe, kill the onboarding flow
                    shouldShowOnboarding = false
                }
            }
        }, content: {
            if isPad {
                if #available(iOS 18.0, *) {
                    PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                        .dynamicTypeSize(.medium...DynamicTypeSize.large)
                        .presentationSizing(.page)
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
                    
                } else {
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
                
            } else {
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
            }
        })
        .sheet(isPresented: $shouldShowLastChance, onDismiss: {
            /// When the Last Chance Offer is dismissed, kill the onboarding flow
            shouldShowOnboarding = false
        }, content: {
            if let offering = offering {
                PaywallView(offering: offering, fonts: CustomPaywallFontProvider(fontName: "Asap"))
                    .interactiveDismissDisabled()
                    .dynamicTypeSize(.medium...DynamicTypeSize.large)
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                DismissButton()
                                    .padding()
                                    .onTapGesture {
                                        shouldShowLastChance = false
                                        self.offering = nil
                                    }
                                Spacer()
                            }
                        }
                    }
                
            } else {
                ProgressView("Loading paywall...")
            }
        })
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                let isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
                
                /// If at any point they subscribe, dismiss any and all paywalls, kill the onboarding flow, and proceed to the app
                if isSubscribed {
                    showPaywall = false
                    offering = nil
                    shouldShowOnboarding = false
                    await subManager.checkTrialStatus()
                }
                
                await subManager.checkSubscriptionStatus()
            }
        }
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
    
    private func lastChanceOfferFetch() {
        Task {
            do {
                let fetchedOffering = try await Purchases.shared.offerings().offering(identifier: "Last Chance Offer")
                await MainActor.run {
                    self.offering = fetchedOffering
                    self.shouldShowLastChance = true
                }
                
            } catch {
                print("ERROR: No Offering Found.")
            }
        }
    }
}

struct PageView: View {
    
    let title: String
    let subtitle: Text
    let videoURL: String
    let showDismissButton: Bool
    let player: AVPlayer?
    var nextAction: () -> Void
    
    @Binding var shouldShowOnboarding: Bool
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
    }
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
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

struct PollView: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
    }
    
    @State private var selectedButton: UserGameImprovement?
    @Binding var shouldShowOnboarding: Bool
    @AppStorage("userGameImprovementSelection") var userGameImprovementSelection = UserGameImprovement.bankroll.rawValue
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("What is your primary focus with poker right now?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 10)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(isZoomed ? 0.5 : 1.0)

                Text("Make your selection below.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 30)
                
                let columns = [GridItem(.adaptive(minimum: 160, maximum: 170)), GridItem(.adaptive(minimum: 160, maximum: 170))]
                
                LazyVGrid(columns: columns) {
                    ForEach(UserGameImprovement.allCases, id: \.self) { text in
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            if selectedButton == text {
                                    selectedButton = nil
                                } else {
                                    selectedButton = text
                                }
                            
                        } label: {
                            Text(text.description)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .frame(height: isZoomed ? 60 : 70)
                                .padding(12)
                                .background(.thinMaterial)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedButton == text ? Color.lightGreen : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .font(.custom("Asap-Regular", size: 16))
                .fontWeight(.heavy)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                userGameImprovementSelection = selectedButton?.rawValue ?? "bankroll"
                Purchases.shared.attribution.setAttributes(["user-game-improvement-selection" : userGameImprovementSelection])
                
                // TODO: NEED TO UPDATE REVENUECAT SDK TO FETCH ONE MORE FUNCTION
//                Purchases.shared.syncAttributesAndOfferingsIfNeeded { offerings, error in
//                    // Put nextAction() func here
//                }
                
                nextAction()
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Continue")
                    .buttonTextStyle()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedButton == nil ? .gray.opacity(0.75) : .white)
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
            .allowsHitTesting(selectedButton == nil ? false : true)
        }
    }
}

struct StartingBankroll: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @AppStorage("savedStartingBankroll") private var savedStartingBankroll: String = ""
    @State private var startingBankrollTextField: String = ""
    @Binding var shouldShowOnboarding: Bool
    @FocusState var isFocused: Bool
    
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
    }
    
    var body: some View {
        
        VStack {
            
            GeometryReader { geo in
                ScrollView {
                    
                    VStack (alignment: .leading) {
                        
                        Spacer()
                        
                        Text("Are you starting off with a bankroll today?")
                            .signInTitleStyle()
                            .foregroundColor(.brandWhite)
                            .fontWeight(.black)
                            .padding(.bottom, 5)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                        
                        Text("You can skip this step, and import data later from a different bankroll tracker.")
                            .calloutStyle()
                            .opacity(0.7)
                            .padding(.bottom, 20)
                        
                        HStack {
                            
                            Text("$")
                                .font(.system(size: 25))
                                .frame(width: 17)
                                .foregroundColor(startingBankrollTextField.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                            
                            TextField("", text: $startingBankrollTextField)
                                .focused($isFocused, equals: true)
                                .font(.custom("Asap-Bold", size: 25))
                                .keyboardType(.numberPad)
                                .onSubmit {
                                    isFocused = false
                                }
                                .toolbar {
                                    ToolbarItem(placement: .keyboard) {
                                        Button("Done") { isFocused = false }
                                    }
                                }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                        .overlay {
                            if !startingBankrollTextField.isEmpty {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.lightGreen, lineWidth: 1.5)
                            }
                        }
                        
                        Spacer()
                        
                    }
                    .frame(minHeight: geo.size.height)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        isFocused = false
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                nextAction()
                
            } label: {
                Text("Skip this step, I'll decide later")
                    .subHeadlineStyle()
                    .buttonStyle(.plain)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                isFocused = false
                savedStartingBankroll = startingBankrollTextField
                nextAction()
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Continue")
                    .buttonTextStyle()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct RiskTolerance: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @State private var selectedTolerance: String? = nil
    @Binding var shouldShowOnboarding: Bool
    @AppStorage("userRiskTolerance") private var selectedRiskTolerance: String = UserRiskTolerance.moderate.rawValue
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("How would you describe your risk tolerance?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("This will help us establish a target bankroll size prior to jumping stakes.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 40)
                
                ForEach(UserRiskTolerance.allCases, id: \.self) { tolerance in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        selectedTolerance = tolerance.rawValue
                        selectedRiskTolerance = selectedTolerance ?? "Conservative"
                        
                    } label: {
                        Text(tolerance.rawValue)
                            .font(.custom("Asap-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.thinMaterial)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        selectedTolerance == tolerance.rawValue ? Color.lightGreen : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 5)
                }
                
                Spacer()
        
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                print("User's selected risk tolerance is: \(selectedRiskTolerance)")
                nextAction()
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Continue")
                    .buttonTextStyle()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedTolerance == nil ? .gray.opacity(0.75) : .white)
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
            .allowsHitTesting(selectedTolerance == nil ? false : true)
        }
    }
}

struct AllowNotifications: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @AppStorage("pushNotificationsAllowed") private var pushNotificationsAllowed = false
    @State private var startingBankrollTextField: String = ""
    @Binding var shouldShowOnboarding: Bool
    @FocusState var isFocused: Bool
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("Enable notifications to crush Live Sessions.")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("We've got your back! Get subtle reminders to stretch, hydrate, and avoid tilt.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 30)
                
                HStack {
                    Spacer()
                    Image("squigleArrow")
                        .resizable()
                        .frame(width: 80, height: 150)
                    Spacer()
                }
                
                Spacer()
        
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                pushNotificationsAllowed = false
                nextAction()
                
            } label: {
                Text("No, thank you")
                    .subHeadlineStyle()
                    .buttonStyle(.plain)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                    if success {
                        pushNotificationsAllowed = true
                        nextAction()
                        
                    } else if let error {
                        print("There was an error: \(error.localizedDescription)")
                        nextAction()
                        
                    } else {
                        nextAction()
                    }
                }
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Allow Notifications")
                    .buttonTextStyle()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

enum UserGameImprovement: String, CaseIterable {
    case bankroll, stakes, mental, hands, expenses, busting
    
    var description: String {
        switch self {
        case .bankroll: "Bankroll Management"
        case .stakes: "Climbing Stakes"
        case .mental: "Mental Game"
        case .hands: "Hand Histories"
        case .expenses: "Tracking Expenses"
        case .busting: "Not Going Bust"
        }
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
