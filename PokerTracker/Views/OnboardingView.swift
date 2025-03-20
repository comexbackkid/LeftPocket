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
            "metrics-screen": AVPlayer(url: Bundle.main.url(forResource: "metrics-screen", withExtension: "mp4")!),
            "tag-reporting": AVPlayer(url: Bundle.main.url(forResource: "tag-reporting", withExtension: "mp4")!),
            "homescreen-widget": AVPlayer(url: Bundle.main.url(forResource: "homescreen-widget", withExtension: "mp4")!),
            "health-metrics": AVPlayer(url: Bundle.main.url(forResource: "health-metrics", withExtension: "mp4")!)
        ]
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
    }
    
    var body: some View {
        
        TabView(selection: $selectedPage) {
            
            WelcomeScreen(selectedPage: $selectedPage).gesture(DragGesture()).tag(0)
            
            PollView(showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(1)
            
            StartingBankroll(showDismissButton: false,
                             nextAction: nextPage,
                             shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(2)
            
//            StudyHabits(showDismissButton: false,
//                        nextAction: nextPage,
//                        shouldShowOnboarding: $shouldShowOnboarding).tag(3)
            
            PageView(title: "Track Your Live Sessions",
                     subtitle: Text("Activate a Live Session by tapping the \(Image(systemName: "cross.fill")) in the navigation bar. To enter rebuys, just press the \(Image(systemName: "dollarsign.arrow.circlepath")) button. Monitor from your lock screen too!"),
                     videoURL: "logging-sessions-new",
                     showDismissButton: false, player: players["logging-sessions-new"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(3)
            
            PageView(title: "Know When to Move Up",
                     subtitle: Text("Insightful charts, progress rings, & crucial player metrics will guide you & advise when it's safe to take a shot at higher stakes."),
                     videoURL: "metrics-screen",
                     showDismissButton: false, player: players["metrics-screen"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(4)
            
            PageView(title: "Session Tags & Reports",
                     subtitle: Text("Easily filter & group together similar Sessions & Transactions by applying a Tag \(Image(systemName: "tag.fill")) to them. Custom Tag reports can be found in your Metrics screen."),
                     videoURL: "tag-reporting",
                     showDismissButton: false, player: players["tag-reporting"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(5)
            
            PageView(title: "Home Screen Widgets",
                     subtitle: Text("Touch & hold an empty area of your home screen until the apps jiggle. Then press the \"Edit\" button, followed by \"Add Widget,\" & search for Left Pocket."),
                     videoURL: "homescreen-widget",
                     showDismissButton: false, player: players["homescreen-widget"],
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(6)
            
            AllowNotifications(showDismissButton: false,
                               nextAction: nextPage,
                               shouldShowOnboarding: $shouldShowOnboarding).tag(7)
            
            PageView(title: "Health & Mindfulness",
                     subtitle: Text("For an optimal experience, Left Pocket requests access to your Health info. This allows us to display your sleep hours & mindful minutes in our Health Analytics page, & integrate these numbers measured by other devices, like an Apple Watch."),
                     videoURL: "health-metrics",
                     showDismissButton: true, player: players["health-metrics"],
                     nextAction: { hkManager.requestAuthorization() },
                     shouldShowOnboarding: $shouldShowOnboarding).gesture(DragGesture()).tag(8)
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
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
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
                .padding(.horizontal, 20)
            
            Spacer()
            
            nextButton
            
        }
    }
    
    var video: some View {
        
        Group {
            if let player = player {
                
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
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
    }
    
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
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(isZoomed ? 0.5 : 1.0)

                Text("Choose any & all that may apply.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, isZoomed ? 10 : 30)
                
//                let columns = [GridItem(.flexible(minimum: 160, maximum: 200)), GridItem(.flexible(minimum: 160, maximum: 200))]
                let columns = [GridItem(.adaptive(minimum: 160, maximum: 170)), GridItem(.adaptive(minimum: 160, maximum: 170))]
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
                                .frame(height: isZoomed ? 60 : 70)
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
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                
                Text("You can skip this step, & import data later from a different bankroll tracker.")
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
            .onTapGesture {
                isFocused = false
            }
            .scrollDismissesKeyboard(.immediately)
            
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

struct StudyHabits: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @State private var selectedHabit: String? = nil
    @Binding var shouldShowOnboarding: Bool
    @FocusState var isFocused: Bool
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("How would you quantify your study habits?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("If your goal is crack the 10 big blinds per hour threshold, let's take accountability.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 40)
                
                ForEach(["Under 3 hrs. per week", "3-5 hrs. per week", "Over 5 hrs. per week"], id: \.self) { habit in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        selectedHabit = habit
                        
                    } label: {
                        Text(habit)
                            .font(.custom("Asap-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.thinMaterial)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(selectedHabit == habit ? Color.lightGreen : Color.clear, lineWidth: 2)
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
                isFocused = false
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
                
                Text("Turn on notifications for help sustaining longer sessions.")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("We've got your back! Receive subtle reminders to stretch, hydrate, & check your focus during Live Sessions.")
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
