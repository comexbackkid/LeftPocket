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
    @StateObject var exportUtility = CSVConversion()
    
    @AppStorage("exportCounter") var exportCounter: Int = 1
    
    @State private var showError: Bool = false
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
                            .tint(.brandPrimary)
                            .onChange(of: isDarkMode) {
                                
                                SystemThemeManager
                                    .shared
                                    .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
                            }
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
                            .tint(.brandPrimary)
                            .onChange(of: systemThemeEnabled, perform: { _ in
                                
                                SystemThemeManager
                                    .shared
                                    .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
                            })
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
                            
                            Text("View saved & default Locations here. Add your own venue, casino, platform, or home game. If you want to delete a Location, tap & hold its thumbnail.")
                                .calloutStyle()
                                .opacity(0.8)
                                .padding(.top, 1)
                        }
                        Spacer()
                    }
                })
            .buttonStyle(PlainButtonStyle())
            
            HStack {
                
                VStack (alignment: .leading) {
                    
                    if subManager.isSubscribed || exportCounter != 0 {
                        
                        Button {
                            
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            
                            do {
                                
                                let fileURL = try CSVConversion.exportCSV(from: vm.sessions)
                                shareFile(fileURL) {
                                    exportCounter = 0
                                }
                                
                            } catch {
                                
                                exportUtility.errorMsg = "\(error.localizedDescription)"
                                showError.toggle()
                                
                            }
                            
                        } label: {
                            
                            HStack {
                                VStack (alignment: .leading) {
                                    HStack {
                                        
                                        Text("Export My Data")
                                            .subtitleStyle()
                                            .bold()
                                        
                                        Spacer()
                                        
                                        Text("›")
                                            .font(.title2)
                                    }
                                    
                                    if !subManager.isSubscribed {
                                        
                                        Text("Upgrade to Left Pocket Pro for unlimited exports. You have \(exportCounter) " + "export\(exportCounter > 0 ? "" : "s") remaining.")
                                            .calloutStyle()
                                            .opacity(0.8)
                                            .padding(.top, 1)
                                        
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alert(isPresented: $showError) {
                            Alert(title: Text("Uh oh!"), message: Text(exportUtility.errorMsg ?? ""), dismissButton: .default(Text("OK")))
                        }
                
                    } else {
                        
                        Button {
                            
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            
                            showPaywall = true
                                
                            
                        } label: {
                            
                            HStack {
                                VStack (alignment: .leading) {
                                    HStack {
                                        
                                        Text("Export My Data")
                                            .subtitleStyle()
                                            .bold()
                                        
                                        Spacer()
                                        
                                        Text("›")
                                            .font(.title2)
                                    }
                                    
                                    Text("Upgrade to Left Pocket Pro for unlimited exports. You have \(exportCounter) " + "export\(exportCounter > 0 ? "" : "s") remaining.")
                                        .calloutStyle()
                                        .opacity(0.8)
                                        .padding(.top, 1)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            
            // MARK: Future Feature Release Coming Soon
            
            if subManager.isSubscribed {
                
                NavigationLink(
                    destination: ImportView()) {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Text("Import Data")
                                        .subtitleStyle()
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("›")
                                        .font(.title2)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                
            } else {
                
                Button {
                    
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    
                    showPaywall = true
                    
                } label: {
                    
                    HStack {
                        VStack (alignment: .leading) {
                            HStack {
                                
                                Text("Import Data")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Text("›")
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
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
                })
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(
                destination: SessionDefaultsView(),
                label: {
                    HStack {
                        
                        VStack (alignment: .leading) {
                            
                            HStack {
                                Text("Session Defaults")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Text("›")
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                    }
                })
            .buttonStyle(PlainButtonStyle())
            
            if !subManager.isSubscribed {
                
                Button {
                    
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    
                    showPaywall = true
                    
                } label: {
                    
                    HStack {
                        Text("Upgrade to Pro")
                            .subtitleStyle()
                            .bold()
                        
                        Spacer()
                        
                        Text("›")
                            .font(.title2)
                    }
                    
                    Spacer()
                }
                .buttonStyle(PlainButtonStyle())
            }
            
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
        }
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
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
            
            Link(destination: URL(string: "mailto:leftpocketpoker@gmail.com")!,
                 label: {
                HStack {
                    
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Email Support")
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
    
    func shareFile(_ fileURL: URL, completion: @escaping () -> Void) {
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            
                // Check if the activity was completed successfully
                if completed {
                    
                    // Run the second parameter, "completion" after success. It takes in a function or action of some kind
                    completion()
                }
            }
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
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
