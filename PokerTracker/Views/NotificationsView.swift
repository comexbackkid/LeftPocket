//
//  NotificationsView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/4/24.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    
    @State private var showAlert = false
    let alertMessage = "Notifications have been disabled at the system level. Please enable them from your device Settings."
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Notifications")
                    .titleStyle()
                    .padding(.top, -37)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            Text("Left Pocket can send a notification every couple of hours checking in on how you're playing during a live session. Tap the button below to allow notifications.")
                .bodyStyle()
                .padding(.horizontal)
                .padding(.bottom)
            
            Button {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus == .denied {
                        DispatchQueue.main.async {
                            showAlert = true
                        }
                    } else {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                            if success {
                                print("All set")
                            } else if let error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            } label: {
                PrimaryButton(title: "Enable Notfications")
            }
            .padding(.bottom, 30)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Uh Oh!"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
            
            Text("To disable notifications, or to re-enable them after disabling, you must do so from your device settings. Follow the steps below.")
                .bodyStyle()
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            VStack (alignment: .leading, spacing: 25) {
                HStack {
                    Image(systemName: "1.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .top)
                        .foregroundColor(Color.brandPrimary)
                    
                    Text("Open the Settings app")
                        .bodyStyle()
                        .padding(.leading, 6)
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "2.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .top)
                        .foregroundColor(Color.brandPrimary)
                    
                    Text("Tap on Notifications")
                        .bodyStyle()
                        .padding(.leading, 6)
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "3.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .top)
                        .foregroundColor(Color.brandPrimary)
                    
                    Text("Scroll down to Left Pocket, and then Disable Notifications")
                        .bodyStyle()
                        .padding(.leading, 6)
                }
                .padding(.horizontal)
            }
         
            
            Spacer()
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.brandBackground)
        
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .preferredColorScheme(.dark)
    }
}
