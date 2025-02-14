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

struct OnboardingView: View {
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var hkManager: HealthKitManager
    @Binding var shouldShowOnboarding: Bool
    @State private var selectedPage: Int = 0
    @State private var showPaywall = false
    
    private let players: [String: AVPlayer] = [
            "logging-sessions-new": AVPlayer(url: Bundle.main.url(forResource: "logging-sessions-new", withExtension: "mp4")!),
            "custom-locations": AVPlayer(url: Bundle.main.url(forResource: "custom-locations", withExtension: "mp4")!),
            "metrics-screen": AVPlayer(url: Bundle.main.url(forResource: "metrics-screen", withExtension: "mp4")!),
            "tag-reporting": AVPlayer(url: Bundle.main.url(forResource: "tag-reporting", withExtension: "mp4")!),
            "homescreen-widget": AVPlayer(url: Bundle.main.url(forResource: "homescreen-widget", withExtension: "mp4")!),
            "advanced-reporting": AVPlayer(url: Bundle.main.url(forResource: "advanced-reporting", withExtension: "mp4")!),
            "health-metrics": AVPlayer(url: Bundle.main.url(forResource: "health-metrics", withExtension: "mp4")!)
        ]
    
    var body: some View {
        
        TabView(selection: $selectedPage) {
            
            WelcomeScreen(selectedPage: $selectedPage).gesture(DragGesture()).tag(0)
            
            PollView(showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(1)
            
            StartingBankroll(showDismissButton: false,
                             nextAction: nextPage,
                             shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(2)
            
            PageView(title: "Easy Live Session Tracking",
                     subtitle: Text("Activate a Live Session by tapping the \(Image(systemName: "cross.fill")) in the navigation bar. To enter rebuys, just press the \(Image(systemName: "dollarsign.arrow.circlepath")) button. Monitor from your lock screen too!"),
                     videoURL: "logging-sessions-new",
                     showDismissButton: false, player: players["logging-sessions-new"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(3)
            
            AllowNotifications(showDismissButton: false, nextAction: nextPage, shouldShowOnboarding: $shouldShowOnboarding).tag(4)
            
            PageView(title: "Custom Location Images",
                     subtitle: Text("Add your own custom locations and header photos. Just navigate to the Settings \(Image(systemName: "gearshape.fill")) screen, tap on Locations, and then press the \(Image(systemName: "plus")) button."),
                     videoURL: "custom-locations",
                     showDismissButton: false, player: players["custom-locations"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(5)
            
            PageView(title: "Know When to Move Up",
                     subtitle: Text("Insightful charts, progress rings, & player metrics help you keep a thumb on your poker performance so you know exactly when to climb stakes."),
                     videoURL: "metrics-screen",
                     showDismissButton: false, player: players["metrics-screen"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(6)
            
            PageView(title: "Session Tags & Reports",
                     subtitle: Text("Sessions & Transactions with a Tag \(Image(systemName: "tag.fill")) you created can be filtered & grouped together in a custom report for things like a trip, or bankroll challenge."),
                     videoURL: "tag-reporting",
                     showDismissButton: false, player: players["tag-reporting"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(7)
            
            PageView(title: "Home Screen Widgets",
                     subtitle: Text("Touch & hold an empty area of your home screen until the apps jiggle. Then press the \"Edit\" button, followed by \"Add Widget,\" & search for Left Pocket."),
                     videoURL: "homescreen-widget",
                     showDismissButton: false, player: players["homescreen-widget"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(8)
            
            PageView(title: "Advanced Data Metrics",
                     subtitle: Text("One place for all your important player data. Reports & analytics on location performance, stakes, monthly returns, & so much more."),
                     videoURL: "advanced-reporting",
                     showDismissButton: false, player: players["advanced-reporting"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(9)
            
            PageView(title: "Health & Mental State",
                     subtitle: Text("For an optimal experience, Left Pocket requests access to your Health info. This allows us to display your sleep hours & mindful minutes in our Health Analytics page, & integrate these numbers measured by other devices, like an Apple Watch."),
                     videoURL: "health-metrics",
                     showDismissButton: true, player: players["health-metrics"],
                     nextAction: { hkManager.requestAuthorization() },
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(10)
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
                                    shouldShowOnboarding = false
                                    showPaywall = false
                            }
                            Spacer()
                        }
                    }
                }
                .onDisappear(perform: {
                    shouldShowOnboarding = false
                })
        }
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }
    
    func nextPage() {
        withAnimation {
            selectedPage += 1
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
    
    var body: some View {
        
        VStack {
            
            video
            
            Text(title)
                .signInTitleStyle()
                .foregroundColor(.brandWhite)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            
            subtitle
                .calloutStyle()
                .lineSpacing(2.5)
                .opacity(0.7)
                .foregroundColor(.brandWhite)
                .padding(.horizontal, 20)
            
            Spacer()
            
            nextButton
            
        }
    }
    
    var video: some View {
        
        Group {
            if let player = player {
                
                VideoPlayer(player: player)
                    .frame(width: 340, height: 340)
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
                Text("Error. Video file not found.")
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
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PollView: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @State private var selectedButtons: Set<String> = []
    @Binding var shouldShowOnboarding: Bool
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Text("Where do you need the most help in your poker career?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.top, 30)
                    .padding(.bottom, 10)

                Text("Choose any & all that may apply.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 30)
                
                let columns = [GridItem(.flexible(minimum: 160, maximum: 200)), GridItem(.flexible(minimum: 160, maximum: 200))]
                let buttonText = ["Bankroll Management", "Moving up Stakes", "Focus", "Mental Game", "Keeping Hand History", "Tracking Expenses", "Not Going Bust", "When To End a Session"]
                
                LazyVGrid(columns: columns) {
                    ForEach(buttonText, id: \.self) { text in
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            if selectedButtons.contains(text) {
                                selectedButtons.remove(text)
                            } else {
                                selectedButtons.insert(text)
                            }
                        } label: {
                            Text(text)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .frame(height: 75)
                                .padding(12)
                                .background(.thinMaterial)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedButtons.contains(text) ? Color.lightGreen : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .font(.custom("Asap-Regular", size: 16))
                .fontWeight(.heavy)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
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
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("Are you starting off with a bankroll today? Enter it below.")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("(You can skip this step, and if you wish, import data from a different bankroll tracker later)")
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
            .padding(.horizontal, 20)
            
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
                
                Spacer()
                
                Spacer()
                
                Text("Allow push notifications during Live Sessions?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("By doing so, we've got your back & will send subtle reminders to stretch, hydrate, & check on how the game is going every few hours.")
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shouldShowOnboarding: .constant(true))
            .environmentObject(SubscriptionManager())
            .environmentObject(HealthKitManager())
    }
}
