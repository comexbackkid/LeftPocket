//
//  UserSettings.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/11/23.
//

import SwiftUI
import RevenueCatUI
import RevenueCat

struct UserSettings: View {
    
    @Binding var isDarkMode: Bool
    @Binding var systemThemeEnabled: Bool
    
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    
    @State private var showPaywall = false
    
    var body: some View {

        NavigationView {
            
            ScrollView(.vertical) {
                
                VStack (spacing: 40) {
                    
                    displayOptions
                    
                    Divider()
                    
                    middleSection
                    
                    Divider()
                    
                    externalLinks
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
                
            }
            .background(Color.brandBackground)
            .navigationBarHidden(true)
        }
        .accentColor(.brandPrimary)
    }
    
    var displayOptions: some View {
        
        VStack (spacing: 40) {
            HStack {
                
                VStack (alignment: .leading) {
                    
                    HStack {
                        Text("Settings")
                            .titleStyle()
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Dark Mode")
                            .subtitleStyle()
                            .bold()
                        
                        Toggle("", isOn: $isDarkMode)
                            .onChange(of: isDarkMode, perform: { _ in
                                SystemThemeManager
                                    .shared
                                    .handleTheme(darkMode: isDarkMode,
                                                 system: systemThemeEnabled)
                            })
                            .tint(.brandPrimary)
                    }
                }
                
                Spacer()
            }
            
            HStack {
                
                VStack (alignment: .leading) {
                    
                    HStack (spacing: -10) {
                        Text("Use System Display")
                            .subtitleStyle()
                            .bold()
                        
                        Toggle("", isOn: $systemThemeEnabled)
                            .onChange(of: systemThemeEnabled, perform: { _ in
                                SystemThemeManager
                                    .shared
                                    .handleTheme(darkMode: isDarkMode,
                                                 system: systemThemeEnabled)
                            })
                            .tint(.brandPrimary)
                    }
                    
                    Text("Using System Display will override Dark Mode and use your current device preferences.")
                        .calloutStyle()
                        .opacity(0.8)
                        .padding(.top, 1)
                }
                Spacer()
                
            }
        }
    }
    
    var middleSection: some View {
        
        VStack (spacing: 40) {
            
            NavigationLink(
                destination: LocationGridView(),
                label: {
                    HStack {
                        
                        VStack (alignment: .leading) {
                            HStack {
                                Text("Locations")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Text("›")
                                    .font(.title2)
                            }
                            Text("View your saved and default locations here. Add your own venue, casino, site, or home game.")
                                .calloutStyle()
                                .opacity(0.8)
                                .padding(.top, 1)
                        }
                        Spacer()
                    }
                }).buttonStyle(PlainButtonStyle())
            
            HStack {
                
                VStack (alignment: .leading) {
                    
                    if subManager.isSubscribed {
                        
                        ShareLink(item: vm.sessionsPath) {
                            
                            HStack {
                                Text("Export My Data")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Text("›")
                                    .font(.title2)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                
                    } else {
                        
                        Button {
                            
                            showPaywall = true
                                
                            
                        } label: {
                            
                            HStack {
                                Text("Export My Data")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Text("›")
                                    .font(.title2)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showPaywall) {
                            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                        }
                        .task {
                            for await customerInfo in Purchases.shared.customerInfoStream {
                                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                                await subManager.checkSubscriptionStatus()
                            }
                        }
                        
                        // The above is working, but need to make sure this is ideal. What's with the double &&?
                        
                    }
                }
                
                Spacer()
            }
            
            NavigationLink(
                destination: HelpView(),
                label: {
                    HStack {
                        
                        VStack (alignment: .leading) {
                            
                            HStack {
                                Text("How-To Guide")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Text("›")
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                    }
                }).buttonStyle(PlainButtonStyle())
        }
        
    }
    
    var externalLinks: some View {
        
        VStack(spacing: 40) {
            
            Link(destination: URL(string: "https://apps.apple.com/us/app/left-pocket/id1601858981")!,
                 label: {
                HStack {
                    
                    VStack (alignment: .leading) {
                        
                        HStack {
                            Text("Leave a Review")
                                .subtitleStyle()
                                .bold()
                            
                            Spacer()
                            
                            Image(systemName: "link").foregroundColor(.brandPrimary)
                        }
                    }
                    
                    Spacer()
                }
            })
            .buttonStyle(PlainButtonStyle())
            
            Link(destination: URL(string: "https://twitter.com/chrisnachtrieb")!,
                 label: {
                HStack {
                    
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Contact Support")
                                .subtitleStyle()
                                .bold()
                            
                            Spacer()
                            
                            Image(systemName: "link").foregroundColor(.brandPrimary)
                        }
                        Text("Click here to reach out to the developer for any bugs or future feature requests.")
                            .calloutStyle()
                            .opacity(0.8)
                            .padding(.top, 1)
                    }
                    
                    Spacer()
                }
            })
            .buttonStyle(PlainButtonStyle())
            
        }
    }
}

struct UserSettings_Previews: PreviewProvider {
    static var previews: some View {
        UserSettings(isDarkMode: .constant(false), systemThemeEnabled: .constant(true))
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
    }
}
