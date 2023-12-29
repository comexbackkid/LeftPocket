//
//  SignInTest.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/12/23.
//

import SwiftUI
import AuthenticationServices

struct SignInTest: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var shouldShowOnboarding: Bool
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Spacer()
                
                logo
                
                Spacer()
                
                bodyText
                
                Spacer()
                
                getStartedButton
                
                disclaimerText
            }
            .padding()
        }
        .onBoardingBackgroundStyle(colorScheme: colorScheme)
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
                .bold()
                .foregroundColor(.white)
                .font(.title)
                .padding(.bottom, 50)
            
        }
        
    }
    
    var getStartedButton: some View {
        
        Button {
            
            shouldShowOnboarding.toggle()
            
        } label: {
            
            Text("Get Started")
                .buttonTextStyle()
                .foregroundColor(.black)
                .font(.title3)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(.white)
                .cornerRadius(30)
                .padding(.horizontal, 10)
            
        }
        .buttonStyle(PlainButtonStyle())
        
    }
    
    var disclaimerText: some View {
        
        Text("By continuing you agree to Left Pocket's Terms of Use and [Privacy Policy](https://getleftpocket.carrd.co/#privacy)")
            .accentColor(.brandPrimary)
            .foregroundColor(.white)
            .font(.footnote)
            .padding()
            .multilineTextAlignment(.center)
    }
    
}

struct SignInTest_Previews: PreviewProvider {
    static var previews: some View {
        SignInTest(shouldShowOnboarding: .constant(true))
//            .preferredColorScheme(.dark)
    }
}
