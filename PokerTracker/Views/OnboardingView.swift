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
            
            PageView(title: "Logging Poker Sessions",
                     subtitle: Text("Add a completed Session, or activate a Live Session by tapping the \(Image(systemName: "plus")) in the navigation bar. To enter rebuys, just press the \(Image(systemName: "dollarsign.arrow.circlepath")) button."),
                     imageName: "doc.text",
                     videoURL: "logging-sessions",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(1)
            
            PageView(title: "Custom Locations",
                     subtitle: Text("Enter your own custom locations and header photos. Navigate to the Settings \(Image(systemName: "gearshape.fill")) screen and tap on Locations."),
                     imageName: "chart.line.uptrend.xyaxis",
                     videoURL: "custom-locations",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(2)
            
            PageView(title: "Advanced iOS Features",
                     subtitle: Text("Add a stunning bankroll widget to your home screen! Tap & hold your iOS wallpaper, press the Plus button & search for Left Pocket."),
                     imageName: "paintbrush",
                     videoURL: "homescreen-widget",
                     showDismissButton: true,
                     nextAction: { showPaywall = true },
                     shouldShowOnboarding: $shouldShowOnboarding).tag(3)
        }
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
