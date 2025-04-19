//
//  UserSettings.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/11/23.
//

import SwiftUI
import RevenueCatUI
import RevenueCat
import StoreKit
import UserNotifications

struct UserSettings: View {
    
    @Binding var isDarkMode: Bool
    @Binding var systemThemeEnabled: Bool
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @StateObject var exportUtility = CSVConversion()
    @AppStorage("exportCounter") var exportCounter: Int = 1
    @AppStorage("hideBankroll") var hideBankroll: Bool = false
    @State private var showError: Bool = false
    @State private var showPaywall = false
    @State private var notificationsAllowed = false
    @State private var showAlertModal = false
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {

        NavigationStack {
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    HStack {
                        Text("Settings")
                            .titleStyle()
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    
                    VStack {
                        
                        displayOptions
                        
                        Divider().padding(.vertical)
                        
                        middleSection
                        
                        Divider().padding(.vertical)
                        
                        bottomSection
                        
                        Divider().padding(.vertical)
                        
                        appVersion
                        
                        Spacer()
                    }
                    .padding(.horizontal, isPad ? 40 : 16)
                    .padding(.bottom, 60)
                }
            }
            .background(Color.brandBackground)
            .navigationBarHidden(true)
        }
        .accentColor(.brandPrimary)
        .dynamicTypeSize(...DynamicTypeSize.large)
    }
    
    var displayOptions: some View {
        
        VStack (spacing: 40) {
            
            HStack {
                
                VStack (alignment: .leading) {
                    
                    if !subManager.isSubscribed {
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            showPaywall = true
                            
                        } label: {
                            HStack {
                                Spacer()
                                VStack {
                                    Text("✨  Try Left Pocket Pro  ✨")
                                        .subtitleStyle()
                                        .environment(\.sizeCategory, .small)
                                    
//                                    Text("Tap here to unlock access")
//                                        .captionStyle()
//                                        .opacity(0.75)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 20)
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 15))
                            .padding(.bottom, 25)
                            
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Dark Mode")
                            .subtitleStyle()
                            .bold()
                        
                        Toggle("", isOn: $isDarkMode)
                            .tint(.brandPrimary)
                            .onChange(of: isDarkMode, perform: { value in
                                SystemThemeManager
                                    .shared
                                    .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
                            })
                    }
                }
                
                Spacer()
            }
            
            HStack {
                
                VStack (alignment: .leading) {
                    
                    Toggle(isOn: $systemThemeEnabled) {
                        Text("Use System Display")
                            .subtitleStyle()
                            .bold()
                    }
                    .tint(.brandPrimary)
                    .onChange(of: hideBankroll, perform: { _ in
                        SystemThemeManager
                            .shared
                            .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
                    })
                    
                    Text("Using System Display will override Dark Mode and use your current device preferences.")
                        .calloutStyle()
                        .opacity(0.8)
                        .padding(.top, 1)
                    
                }
                
                Spacer()
                
            }
            
            HStack {
                
                VStack (alignment: .leading) {
                    
                    Toggle(isOn: $hideBankroll) {
                        Text("Incognito Bankroll")
                            .subtitleStyle()
                            .bold()
                    }
                    .tint(.brandPrimary)
                    .onChange(of: hideBankroll, perform: { _ in
                        hideBankroll.toggle()
                    })
                    
                    Text("Hide your bankroll in your Dasbhoard to conceal sensitive information.")
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
            
            locations
            
            NavigationLink {
                NotificationsView()
            } label: {
                HStack {
                    
                    VStack (alignment: .leading) {
                        
                        HStack {
                            Text("Push Notifications")
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
            
            sessionDefaults
            
            dashboardConfig
            
            importData
            
            exportData
            
            Group {
                if subManager.isSubscribed {
                    NavigationLink(
                        destination: ManageBankrolls(),
                        label: {
                            HStack {
                                
                                VStack (alignment: .leading) {
                                    
                                    HStack {
                                        Text("Manage Bankrolls")
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
                    
                } else {
                    Button {
                        showPaywall = true
                        
                    } label: {
                        HStack {
                            
                            VStack (alignment: .leading) {
                                
                                HStack {
                                    Text("Manage Bankrolls")
                                        .subtitleStyle()
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "lock.fill")
                                        .font(.title2)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            howToGuide
            
        }
        .fullScreenCover(isPresented: $showPaywall, content: {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                .dynamicTypeSize(.large)
                .overlay {
                    HStack {
                        Spacer()
                        VStack {
                            DismissButton()
                                .padding(.horizontal)
                                .onTapGesture {
                                    showPaywall = false
                            }
                            Spacer()
                        }
                    }
                }
        })
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }
    
    var locations: some View {
        
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
                        
                        Text("Add your own venue, casino, platform, or home game. If you want to delete a Location, tap & hold its thumbnail.")
                            .calloutStyle()
                            .opacity(0.8)
                            .padding(.top, 1)
                    }
                    Spacer()
                }
            })
        .buttonStyle(PlainButtonStyle())
        
    }
    
    var sessionDefaults: some View {
        
        HStack {
            
            NavigationLink(
                destination: SessionDefaultsView(isPresentedAsSheet: .constant(false)),
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
        }
    }
    
    var dashboardConfig: some View {
        
        VStack {
            if subManager.isSubscribed {
                NavigationLink(
                    destination: DashboardConfig(),
                    label: {
                        HStack {
                            
                            VStack (alignment: .leading) {
                                
                                HStack {
                                    Text("Dashboard Layout")
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
                
            } else {
                
                Button {
                    showPaywall = true
                } label: {
                    
                    HStack {
                        
                        VStack (alignment: .leading) {
                            
                            HStack {
                                Text("Dashboard Layout")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Image(systemName: "lock.fill")
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var bottomSection: some View {
        
        VStack(spacing: 40) {
            
            redeemOfferCode
            
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
    
    var exportButtonContent: some View {
        
        HStack {
            Text("Export Sessions")
                .subtitleStyle()
                .bold()
            
            Spacer()
            
            Text("›")
                .font(.title2)
        }
    }
    
    var exportData: some View {

        VStack (spacing: 40) {
            
            // MARK: EXPORT SESSIONS
            HStack {
                
                VStack (alignment: .leading) {
                    
                    if let sessionsFileURL = try? CSVConversion.exportCSV(from: vm.allSessions) {
                        ShareLink(item: sessionsFileURL) {
                            exportButtonContent
                                
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        Button {
                            exportUtility.errorMsg = "Export failed. No Session data was found."
                            showError = true
                            
                        } label: {
                            exportButtonContent
                        }
                        .buttonStyle(.plain)
                        .alert(isPresented: $showError) {
                            Alert(title: Text("Uh oh!"),
                                  message: Text(exportUtility.errorMsg ?? "Export failed. No Session data was found."),
                                  dismissButton: .default(Text("OK")))
                        }
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showAlertModal, content: {
                AlertModal(message: "Your data was exported successfully.")
                    .presentationDetents([.height(210)])
                    .presentationBackground(.ultraThinMaterial)
            })
            
            // MARK: EXPORT TRANSACTIONS
            if subManager.isSubscribed {
                HStack {
                    
                    if let transactionsFileURL = try? CSVConversion.exportTransactionsCSV(from: vm.allTransactions) {
                        ShareLink(item: transactionsFileURL) {
                            HStack {
                                HStack {
                                    Text("Export Transactions")
                                        .subtitleStyle()
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("›")
                                        .font(.title2)
                                }
                            }
                                
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        Button {
                            exportUtility.errorMsg = "Export failed. No Transactions data was found."
                            showError = true
                            
                        } label: {
                            HStack {
                                HStack {
                                    Text("Export Transactions")
                                        .subtitleStyle()
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("›")
                                        .font(.title2)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .alert(isPresented: $showError) {
                            Alert(title: Text("Uh oh!"),
                                  message: Text(exportUtility.errorMsg ?? "Export failed. No Transactions data was found."),
                                  dismissButton: .default(Text("OK")))
                        }
                    }
                    
                    Spacer()
                }
                
            } else {
                HStack {
                    
                    Button {
                        showPaywall = true
                        
                    } label: {
                        HStack {
                            HStack {
                                Text("Export Transactions")
                                    .subtitleStyle()
                                    .bold()
                                
                                Spacer()
                                
                                Image(systemName: "lock.fill")
                                    .font(.title2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            }
        }
    }
    
    var importData: some View {
        
        HStack {
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
        }
    }
    
    var howToGuide: some View {
        
        NavigationLink(
            destination: UsingLeftPocket(),
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
        
    }
    
    var redeemOfferCode: some View {
        
        NavigationLink {
            RedeemOfferCode()
        } label: {
            HStack {
                
                VStack (alignment: .leading) {
                    
                    HStack {
                        Text("Redeem Offer Code")
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
        .buttonStyle(.plain)
    }
    
    var appVersion: some View {
        HStack {
            
            Text("Left Pocket v" + getAppVersion())
                .captionStyle()
                .opacity(0.8)
            
            Spacer()
        }
    }
    
    func shareFile(_ fileURL: URL, from sourceView: UIView? = nil, completion: @escaping () -> Void) {
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        // iPad-specific presentation
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = sourceView ?? UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow })
        }
        
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            if completed {
                showAlertModal = true
                completion()
            }
        }
        
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController {
            topVC.present(activityViewController, animated: true)
        }
        
//        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
//            
//                // Check if the activity was completed successfully
//                if completed {
//                    showAlertModal = true
//                    
//                    // Run the second parameter, "completion" after success. It takes in a function or action of some kind
//                    completion()
//                }
//            }
//        
//        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
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
