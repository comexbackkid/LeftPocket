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
    @State private var showSuccessAlert = false
    @AppStorage("pushNotificationsAllowed") private var notificationsAllowed: Bool?
    
    let alertMessage = "Notifications have been disabled at the system level. Please enable them in your device's settings."
    
    var body: some View {
        
        ScrollView {
            
            VStack (alignment: .leading) {
                
                title
                
                description
                
                button
                
                Divider().padding()
                
                bottomDescription
                
                Spacer()
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.brandBackground)
            .onAppear(perform: {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus != .authorized {
                        notificationsAllowed = false
                    }
                }
            })
            .sheet(isPresented: $showSuccessAlert, content: {
                AlertModal(message: "Notifications successfully enabled. You can now receive Live Session check ins.")
                    .presentationDetents([.height(210)])
                    .presentationBackground(.ultraThinMaterial)
                
            })
        }
        .background(Color.brandBackground)
    }
    
    var title: some View {
        
        HStack {
            Text("Notifications")
                .titleStyle()
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var description: some View {
        
        Text("Left Pocket can help make sure you're fresh & on top of your game during Live Sessions with gentle reminders & check ins. Tap the button below to allow notifications.")
            .bodyStyle()
            .padding(.horizontal)
            .padding(.bottom)
        
    }
    
    var button: some View {
        
        Button {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                
                if settings.authorizationStatus == .denied {
                    DispatchQueue.main.async {
                        showAlert = true
                    }
                    
                } else {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                        if success {
                            notificationsAllowed = true
                            showSuccessAlert = true
                            
                        } else if let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
        } label: {
            PrimaryButton(title: notificationsAllowed == true ? "Notifications Allowed" : "Enable Notfications",
                          color: notificationsAllowed == true ? Color.gray : .brandPrimary)
        }
        .allowsHitTesting(notificationsAllowed == true ? false : true)
        .padding(.bottom, 10)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Uh Oh!"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
    }
    
    var bottomDescription: some View {
        
        VStack {
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
        }
        
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .preferredColorScheme(.dark)
    }
}
