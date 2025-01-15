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
        .ignoresSafeArea()
        .dynamicTypeSize(...DynamicTypeSize.large)
        .onBoardingBackgroundStyle(colorScheme: .light)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
                .padding(.bottom, 50)
            
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shouldShowOnboarding: .constant(true))
            .environmentObject(SubscriptionManager())
            .environmentObject(HealthKitManager())
    }
}
