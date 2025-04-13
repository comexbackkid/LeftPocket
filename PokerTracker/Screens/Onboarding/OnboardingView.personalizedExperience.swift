//
//  OnboardingView.personalizedExperience.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/13/25.
//

import SwiftUI
import Lottie

struct PersonalizedExperience: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @Binding var shouldShowOnboarding: Bool
    @State private var progressBarComplete = false
    @State var playbackMode = LottiePlaybackMode.paused(at: .progress(0))
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                LottieView(animation: .named("Lottie-Confetti"))
                    .playbackMode(playbackMode)
                    .animationDidFinish { _ in
                        playbackMode = .paused
                    }
                
                Spacer()
            }
            .offset(y: -175)
            
            VStack {
                
                VStack (alignment: .leading) {
                    
                    Spacer()
                    
                    Text("Congratulations! You're almost done.")
                        .signInTitleStyle()
                        .foregroundColor(.brandWhite)
                        .fontWeight(.black)
                        .padding(.bottom, 5)
                        .padding(.horizontal, 20)
                    
                    Text("Sit tight while we configure the app for you. This will only take a few seconds.")
                        .calloutStyle()
                        .opacity(0.7)
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                    
                    ProgressAnimation()
                    
                    Spacer()
                    
                }
                
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
                        .background(progressBarComplete ? .white : .gray.opacity(0.75))
                        .cornerRadius(30)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                }
                .buttonStyle(PlainButtonStyle())
                .allowsHitTesting(progressBarComplete ? true : false)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    progressBarComplete = true
                    playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
                }
            }
            .sensoryFeedback(.success, trigger: progressBarComplete)
        }
    }
}
