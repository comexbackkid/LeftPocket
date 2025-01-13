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
    
    var body: some View {
        
        TabView(selection: $selectedPage) {
            
            WelcomeScreen(selectedPage: $selectedPage).tag(0)
            
            PollView(showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(1)
            
            PageView(title: "Log Poker Sessions Fast",
                     subtitle: Text("Add a completed Session, or activate a Live Session by tapping the \(Image(systemName: "cross.fill")) in the navigation bar from any screen. To enter rebuys, press the \(Image(systemName: "dollarsign.arrow.circlepath")) button. Use Transactions to log deposits, withdrawals, & expenses to your bankroll."),
                     imageName: "doc.text",
                     videoURL: "logging-sessions-new",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(2)
            
            PageView(title: "Add Locations & Photos",
                     subtitle: Text("Enter your own custom locations and header photos. Just navigate to the Settings \(Image(systemName: "gearshape.fill")) screen, tap on Locations, and then press the \(Image(systemName: "plus")) button."),
                     imageName: "chart.line.uptrend.xyaxis",
                     videoURL: "custom-locations",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(3)
            
            PageView(title: "Advanced Data Reports",
                     subtitle: Text("One place for all your important player data. Reports & analytics on location performance, stakes, month-by-month returns, & much more."),
                     imageName: "paintbrush",
                     videoURL: "advanced-reporting",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(4)
            
            PageView(title: "Home Screen Widgets",
                     subtitle: Text("Add a stunning bankroll widget to your home screen! Touch & hold an empty area of your home screen until the apps jiggle. Then press the \"Edit\" button, followed by \"Add Widget\", & search for Left Pocket."),
                     imageName: "paintbrush",
                     videoURL: "homescreen-widget",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(5)
            
            PageView(title: "Health & Mental State",
                     subtitle: Text("For an optimal experience, Left Pocket needs access to your Health information. This allows us to display your sleep hours & mindful minutes within our Health Analytics section, & integrate numbers measured by other devices, like an Apple Watch."),
                     imageName: "paintbrush",
                     videoURL: "health-metrics",
                     showDismissButton: true,
                     nextAction: { hkManager.requestAuthorization() },
                     shouldShowOnboarding: $shouldShowOnboarding).tag(6)
        }
        .dynamicTypeSize(...DynamicTypeSize.large)
        .onBoardingBackgroundStyle(colorScheme: .light)
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .preferredColorScheme(.dark)
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
    
    @State private var player: AVPlayer?
    
    let title: String
    let subtitle: Text
    let imageName: String
    let videoURL: String
    let showDismissButton: Bool
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
            
            let url = Bundle.main.url(forResource: videoURL, withExtension: "mp4")
            
            if let url = url {
                VideoPlayer(player: player)
                    .frame(width: 340, height: 340)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.vertical, 30)
                    .onAppear {
                        setupPlayer(with: url)
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
            } else {
                Text("Error. Video file not found.")
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
                .padding(.bottom, 65)
            
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func setupPlayer(with url: URL) {
        
        self.player = AVPlayer(url: url)
        self.player?.play()
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: self.player?.currentItem,
            queue: .main
        ) { _ in
            self.player?.seek(to: .zero)
            self.player?.play()
        }
    }
    
}

struct PollView: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @State private var bankrollManagement = false
    @State private var jumpStakes = false
    @State private var focus = false
    @State private var mentalGame = false
    @State private var notGoingBust = false
    @State private var trackingExpenses = false
    @State private var handHistory = false
    @State private var whenToEndSession = false
    
    @Binding var shouldShowOnboarding: Bool
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                Text("Where do you need the most help in your poker career?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.vertical, 30)

                Text("Choose all that apply:")
                    .headlineStyle()
                    .padding(.bottom)
                
                VStack (spacing: 20) {
                    HStack {
                        Text("Bankroll Management")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            bankrollManagement.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(bankrollManagement == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: bankrollManagement)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(bankrollManagement == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Moving up Stakes")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            jumpStakes.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(jumpStakes == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: jumpStakes)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(jumpStakes == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Focus While Playing")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            focus.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(focus == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: focus)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(focus == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Mental Wellbeing")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            mentalGame.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(mentalGame == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: mentalGame)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(mentalGame == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Tracking Expenses")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            trackingExpenses.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(trackingExpenses == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: trackingExpenses)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(trackingExpenses == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Reviewing Hand History")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            handHistory.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(handHistory == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: handHistory)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(handHistory == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("When to End a Session")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            whenToEndSession.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(whenToEndSession == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: whenToEndSession)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(whenToEndSession == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Not Going Bust")
                            .calloutStyle()
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            notGoingBust.toggle()
                        } label: {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(notGoingBust == true ? .green : .gray)
                                    .symbolEffect(.bounce, value: notGoingBust)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(notGoingBust == true ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(25)
                .background(.thinMaterial)
                .cornerRadius(12)
                .padding(.horizontal, 15)
            }
            .padding(.horizontal, 25)
            
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
                    .padding(.bottom, 65)
                
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
