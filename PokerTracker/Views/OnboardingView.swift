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
            PageView(title: "Track Games",
                     subtitle: "Keep track of all your poker sessions. Enter your profit, location, duration, & table stakes.",
                     imageName: "doc.text",
                     showDismissButton: false,
                     shouldShowOnboarding: $shouldShowOnboarding)
            
            PageView(title: "Analyze Progress",
                     subtitle: "Stay on top of your progress as a poker player with useful analytics & bankroll tracking.",
                     imageName: "chart.line.uptrend.xyaxis",
                     showDismissButton: false,
                     shouldShowOnboarding: $shouldShowOnboarding)
            
            PageView(title: "Clean Design",
                     subtitle: "Simplistic, modern user interface for an easier time navigating and reviewing data.",
                     imageName: "paintbrush",
                     showDismissButton: false,
                     shouldShowOnboarding: $shouldShowOnboarding)
            
            PageView(title: "Let's Go!",
                     subtitle: "Get started by clicking below and then adding your first location & session.",
                     imageName: "suit.spade.fill",
                     showDismissButton: true,
                     shouldShowOnboarding: $shouldShowOnboarding)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.brandPrimary, Color.purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .tabViewStyle(PageTabViewStyle())
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.light)
    }
}

struct PageView: View {
    
    let title: String
    let subtitle: String
    let imageName: String
    let showDismissButton: Bool
    
    @Binding var shouldShowOnboarding: Bool
    
    var body: some View {
        
        ZStack {
            if showDismissButton {
                VStack {
                    Button(action: {
                        shouldShowOnboarding.toggle()
                    }, label: {
                        PrimaryButton(title: "Get Started")
                    })
                    .padding(.top, 340)
                }
            }
            
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color("brandWhite"))
                    .opacity(0.5)
                    .padding(50)
                
                Text(title)
                    .foregroundColor(Color("brandWhite"))
                    .font(.title)
                    .bold()
                    .padding(.bottom, 2)
                
                Text(subtitle)
                    .font(.subheadline)
                    .opacity(0.7)
                    .foregroundColor(Color("brandWhite"))
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
            }
            .padding(.bottom, 140)
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(shouldShowOnboarding: .constant(true))
    }
}
