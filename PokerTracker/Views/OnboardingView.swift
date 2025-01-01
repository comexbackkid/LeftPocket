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
    @Binding var shouldShowOnboarding: Bool
    @State private var selectedPage: Int = 0
    @State private var showPaywall = false
    
    var body: some View {
        
        TabView(selection: $selectedPage) {
            
            WelcomeScreen(selectedPage: $selectedPage).tag(0)
            
            PageView(title: "Log Sessions Quickly",
                     subtitle: Text("Add a completed Session, or activate a Live Session by tapping the \(Image(systemName: "cross.fill")) in the navigation bar from any screen. To enter rebuys, press the \(Image(systemName: "dollarsign.arrow.circlepath")) button. Use Transactions to log deposits, withdrawals, & expenses to your bankroll."),
                     imageName: "doc.text",
                     videoURL: "logging-sessions-new",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(1)
            
            PageView(title: "Locations & Photos",
                     subtitle: Text("Enter your own custom locations and header photos. Just navigate to the Settings \(Image(systemName: "gearshape.fill")) screen, tap on Locations, and then tap the \(Image(systemName: "plus")) button."),
                     imageName: "chart.line.uptrend.xyaxis",
                     videoURL: "custom-locations",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(2)
            
            PageView(title: "Home Screen Widgets",
                     subtitle: Text("Add a stunning bankroll widget to your home screen! Touch & hold an empty area of your home screen until the apps jiggle. Then press the \"Edit\" button, followed by \"Add Widget\", & search for Left Pocket."),
                     imageName: "paintbrush",
                     videoURL: "homescreen-widget",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(3)
            
            PageView(title: "Health & Performance",
                     subtitle: Text("Pro members have access to our one-of-a-kind Health Analytics suite that tracks sleep, mental wellbeing, & correlates your health data to your poker performance!"),
                     imageName: "paintbrush",
                     videoURL: "health-metrics",
                     showDismissButton: true,
                     nextAction: { showPaywall = true },
                     shouldShowOnboarding: $shouldShowOnboarding).tag(4)
        }
        .dynamicTypeSize(...DynamicTypeSize.large)
        .onBoardingBackgroundStyle(colorScheme: .light)
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .preferredColorScheme(.dark)
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
                .subHeadlineStyle()
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
            
            Text(showDismissButton ? "Get Started" : "Continue")
                .buttonTextStyle()
                .foregroundColor(.black)
                .font(.title3)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shouldShowOnboarding: .constant(true))
            .environmentObject(SubscriptionManager())
    }
}
