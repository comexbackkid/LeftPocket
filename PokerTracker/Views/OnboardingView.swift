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
            
            WelcomeScreen(selectedPage: $selectedPage).tag(0).gesture(DragGesture())
            
            PollView(showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(1).gesture(DragGesture())
            
            StartingBankroll(showDismissButton: false,
                             nextAction: nextPage,
                             shouldShowOnboarding: $shouldShowOnboarding).tag(2).gesture(DragGesture())
            
            PageView(title: "Easy Live Session Tracking",
                     subtitle: Text("Activate a Live Session by tapping the \(Image(systemName: "cross.fill")) in the navigation bar. To enter rebuys, just press the \(Image(systemName: "dollarsign.arrow.circlepath")) button. Monitor from your lock screen too!"),
                     imageName: "doc.text",
                     videoURL: "logging-sessions-new",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(3).gesture(DragGesture())
            
            PageView(title: "Custom Location Images",
                     subtitle: Text("Add your own custom locations and header photos. Just navigate to the Settings \(Image(systemName: "gearshape.fill")) screen, tap on Locations, and then press the \(Image(systemName: "plus")) button."),
                     imageName: "chart.line.uptrend.xyaxis",
                     videoURL: "custom-locations",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(4).gesture(DragGesture())
            
            PageView(title: "Know When to Move Up",
                     subtitle: Text("Insightful charts, progress rings, & player metrics help you keep a thumb on your poker performance so you know exactly when to climb stakes."),
                     imageName: "chart.line.uptrend.xyaxis",
                     videoURL: "metrics-screen",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(5).gesture(DragGesture())
            
            PageView(title: "Session Tags & Reports",
                     subtitle: Text("Sessions & Transactions with a Tag \(Image(systemName: "tag.fill")) you created can be filtered & grouped together in a custom report for things like a trip, or bankroll challenge."),
                     imageName: "chart.line.uptrend.xyaxis",
                     videoURL: "tag-reporting",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(6).gesture(DragGesture())
            
            PageView(title: "Home Screen Widgets",
                     subtitle: Text("Touch & hold an empty area of your home screen until the apps jiggle. Then press the \"Edit\" button, followed by \"Add Widget,\" & search for Left Pocket."),
                     imageName: "paintbrush",
                     videoURL: "homescreen-widget",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(7).gesture(DragGesture())
            
            PageView(title: "Advanced Data Metrics",
                     subtitle: Text("One place for all your important player data. Reports & analytics on location performance, stakes, monthly returns, & so much more."),
                     imageName: "paintbrush",
                     videoURL: "advanced-reporting",
                     showDismissButton: false,
                     nextAction: nextPage,
                     shouldShowOnboarding: $shouldShowOnboarding).tag(8).gesture(DragGesture())
            
            PageView(title: "Health & Mental State",
                     subtitle: Text("For an optimal experience, Left Pocket requests access to your Health info. This allows us to display your sleep hours & mindful minutes in our Health Analytics page, & integrate these numbers measured by other devices, like an Apple Watch."),
                     imageName: "paintbrush",
                     videoURL: "health-metrics",
                     showDismissButton: true,
                     nextAction: { hkManager.requestAuthorization() },
                     shouldShowOnboarding: $shouldShowOnboarding).tag(9).gesture(DragGesture())
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shouldShowOnboarding: .constant(true))
            .environmentObject(SubscriptionManager())
            .environmentObject(HealthKitManager())
    }
}
