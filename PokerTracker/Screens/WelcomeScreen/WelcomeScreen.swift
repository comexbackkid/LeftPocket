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
                
                logo
                
                Spacer()
                
                bodyText
                
                Spacer()
                
                disclaimerText
                
                getStartedButton
                
            }
        }
    }
    
    var logo: some View {
        
        Image("leftpocket-logo-simple")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 200)
    }
    
    var bodyText: some View {
        
        VStack {
            
            Text("WELCOME TO LEFT POCKET")
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.light)
                .padding(.bottom, 1)
            
            Text("Where you keep your important money.")
                .signInTitleStyle()
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
                selectedPage = 1
            }
            
        } label: {
            
            Text("Let's Begin")
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
    
    var disclaimerText: some View {
        
        Text("By continuing you agree to Left Pocket's Terms of Use and our [Privacy Policy](https://getleftpocket.com/#privacy).")
            .accentColor(.brandPrimary)
            .foregroundColor(.white)
            .font(.footnote)
            .padding()
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

struct SignInTest_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(selectedPage: .constant(0))
            .onBoardingBackgroundStyle(colorScheme: .light)
            .environmentObject(SubscriptionManager())
    }
}
