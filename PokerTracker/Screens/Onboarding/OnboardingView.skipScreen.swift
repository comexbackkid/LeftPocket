//
//  OnboardingView.skipScreen.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/13/25.
//

import SwiftUI

struct SkipScreen: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    var skipToEnd: () -> Void
    
    @AppStorage("pushNotificationsAllowed") private var pushNotificationsAllowed = false
    @State private var startingBankrollTextField: String = ""
    @Binding var shouldShowOnboarding: Bool
    @FocusState var isFocused: Bool
    
    var body: some View {
        
        VStack {
            
            HStack {
                VStack (alignment: .leading) {
                    
                    Spacer()
                    
                    Text("We need to ask a few questions to customize your experience.")
                        .signInTitleStyle()
                        .foregroundColor(.brandWhite)
                        .fontWeight(.black)
                        .padding(.bottom, 5)
                    
                    Text("If you'd prefer to skip ahead and hurt our feelings, tap \"Skip to the End\" below.")
                        .calloutStyle()
                        .opacity(0.7)
                        .padding(.bottom, 30)
                    
                    Spacer()
            
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                skipToEnd()
                
            } label: {
                Text("No thanks, skip to the end")
                    .subHeadlineStyle()
                    .buttonStyle(.plain)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)
            
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

#Preview {
    SkipScreen(showDismissButton: false, nextAction: {}, skipToEnd: {}, shouldShowOnboarding: .constant(true))
}
