//
//  SignInTest.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/12/23.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct WelcomeScreen: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var subManager: SubscriptionManager
    @Binding var selectedPage: Int
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Spacer()
                
                bodyText
                
                getStartedButton
                
                disclaimerText
            }
        }
        .background(
            GeometryReader { geometry in
                Image("welcome-screen-bg-5")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        Image("welcome-screen-bg-5")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 20, opaque: true)
                            .mask(
                                LinearGradient(gradient: Gradient(stops: [
                                    Gradient.Stop(color: Color(white: 0, opacity: 0), location: 0.5),
                                    Gradient.Stop(color: Color(white: 0, opacity: 1), location: 0.7),
                                ]), startPoint: .top, endPoint: .bottom)
                            )
                    }
                    .overlay(
                        LinearGradient(gradient: Gradient(stops: [
                            Gradient.Stop(color: Color(white: 0, opacity: 0.0), location: 0.4),
                            Gradient.Stop(color: Color(white: 0, opacity: 0.7), location: 0.9),
                        ]), startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: geometry.size.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .ignoresSafeArea()
            }
        )
    }
    
    var bodyText: some View {
        
        VStack (spacing: 10) {
            
            Text("WELCOME TO LEFT POCKET")
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.light)
            
            Text("Bankroll management for aspiring players.")
                .signInTitleStyle()
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.bottom, 50)
            
        }
        .padding(.horizontal)
    }
    
    var getStartedButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            withAnimation {
                selectedPage += 1
            }
            
        } label: {
            Text("Let's Begin")
                .buttonTextStyle()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.white)
                .cornerRadius(30)
                .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var disclaimerText: some View {
        
        Text("By continuing you agree to Left Pocket's Terms of Use and our [Privacy Policy](https://getleftpocket.com/#privacy).")
            .accentColor(.brandPrimary)
            .foregroundColor(.white)
            .font(.footnote)
            .padding()
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.bottom, 10)
    }
    
    var avgUserRating: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Image(systemName: "laurel.leading")
                    .imageScale(.large)
                    .fontWeight(.black)
                Text("4.7")
                    .font(.custom("Asap-Black", size: 42))
                    .bold()
                Image(systemName: "laurel.trailing")
                    .imageScale(.large)
                    .fontWeight(.black)
                Spacer()
            }
            
            Text("Avg. Customer Rating")
                .captionStyle()
            
            HStack (spacing: 2) {
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
            }
            .imageScale(.medium)
            .fontWeight(.black)
            .foregroundStyle(.orange)
            .padding(.top, 1)
        }
        .padding(.bottom, 35)
    }
}

struct SignInTest_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(selectedPage: .constant(0))
            .onBoardingBackgroundStyle(colorScheme: .light)
            .environmentObject(SubscriptionManager())
    }
}
