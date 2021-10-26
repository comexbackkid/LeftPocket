//
//  OnboardingView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/18/21.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding var shouldShowOnboarding: Bool
    
    var body: some View {
        TabView {
            PageView(title: "Track",
                     subtitle: "Keep track of all your poker sessions. Save your profit, location, duration, and expenses.",
                     imageName: "pencil.tip.crop.circle",
                     showDismissButton: false,
                     shouldShowOnboarding: $shouldShowOnboarding)
            
            PageView(title: "Analyze",
                     subtitle: "Stay on top of your progress as a poker player with useful analytics and bankroll tracking.",
                     imageName: "waveform.path.ecg",
                     showDismissButton: false,
                     shouldShowOnboarding: $shouldShowOnboarding)
            
            PageView(title: "Start", subtitle: "Get started by clicking below and then adding your very first poker session!", imageName: "suit.spade.fill",
                     showDismissButton: true,
                     shouldShowOnboarding: $shouldShowOnboarding)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct PageView: View {
    
    let title: String
    let subtitle: String
    let imageName: String
    let showDismissButton: Bool
    @Binding var shouldShowOnboarding: Bool
    
    var body: some View {
        
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(Color("brandPrimary"))
                .padding(50)
            
            Text(title)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .bold()
                .padding(.bottom, 2)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            if showDismissButton {
                Button(action: {
                    shouldShowOnboarding.toggle()
                }, label: {
                    PrimaryButton(title: "Get Started")
                })
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shouldShowOnboarding: .constant(true))
    }
}
