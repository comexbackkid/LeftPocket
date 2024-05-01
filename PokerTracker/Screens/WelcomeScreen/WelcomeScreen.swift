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
    @Binding var showWelcomeScreen: Bool
    
    @State var showPaywall = false
    
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
        .onBoardingBackgroundStyle(colorScheme: .light)
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
                                    showWelcomeScreen = false
                                    showPaywall = false
                            }
                            Spacer()
                        }
                    }
                }
                .onDisappear(perform: {
                    showWelcomeScreen = false
                })
        }
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
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
                .bold()
                .foregroundColor(.white)
                .font(.title)
                .padding(.bottom, 50)
            
        }
        
    }
    
    var getStartedButton: some View {
        
        Button {
            
            showPaywall = true
//            showWelcomeScreen.toggle()
            
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
        
        Text("By continuing you agree to Left Pocket's Terms of Use and [Privacy Policy](https://getleftpocket.com/#privacy)")
            .accentColor(.brandPrimary)
            .foregroundColor(.white)
            .font(.footnote)
            .padding()
            .multilineTextAlignment(.center)
    }
}

struct SignInTest_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(showWelcomeScreen: .constant(true))
            .environmentObject(SubscriptionManager())
    }
}
