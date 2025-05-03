//
//  OnboardingView.allowNotifications.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/19/25.
//

import SwiftUI

struct AllowNotifications: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @AppStorage("pushNotificationsAllowed") private var pushNotificationsAllowed = false
    @State private var startingBankrollTextField: String = ""
    @Binding var shouldShowOnboarding: Bool
    @FocusState var isFocused: Bool
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("Enable notifications to crush Live Sessions.")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("We've got your back! Get subtle reminders to stretch, hydrate, and avoid tilt.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 40)
                
                HStack {
                    Image("notifications-onboarding-screenshot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                Spacer()
        
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                pushNotificationsAllowed = false
                nextAction()
                
            } label: {
                Text("No, thank you")
                    .subHeadlineStyle()
                    .buttonStyle(.plain)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                    if success {
                        pushNotificationsAllowed = true
                        nextAction()
                        
                    } else if let error {
                        print("There was an error: \(error.localizedDescription)")
                        nextAction()
                        
                    } else {
                        nextAction()
                    }
                }
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Allow Notifications")
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
