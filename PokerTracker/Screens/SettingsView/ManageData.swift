//
//  ManageData.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/21/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct ManageData: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showError: Bool = false
    @State private var showDeleteWarning = false
    @State private var showPaywall = false
    @State private var notificationsAllowed = false
    @State private var showAlertModal = false
    @State private var showDeleteSuccessAlertModal = false
    @State private var showExportSuccessAlertModal = false
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @StateObject var exportUtility = CSVConversion()
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    titleInstructions
                    
                    VStack (spacing: 40) {
                        
                        importData
                        
                        exportData
                        
                        restoreData
                        
                        deleteData
                        
                        Spacer()
                    }
                    .padding(.horizontal, isPad ? 40 : 16)
                    .padding(.bottom, 60)
                }
            }
            .background(Color.brandBackground)
        }
        .accentColor(.brandPrimary)
        .dynamicTypeSize(...DynamicTypeSize.large)
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
    }
    
    var titleInstructions: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("Manage Data")
                    .titleStyle()
                    .padding(.horizontal)
                
                Spacer()
            }
            
            HStack {
                Text("Manage all your data from this screen. To bring in data from another tracker, tap Import Data below.")
                    .bodyStyle()
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 25)
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
            .sheet(isPresented: $showExportSuccessAlertModal, content: {
                AlertModal(message: "Your data was exported successfully.", image: "checkmark.circle", imageColor: .green)
                    .presentationDetents([.height(280)])
                    .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                    .presentationDragIndicator(.visible)
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
    
    var restoreData: some View {
        
        NavigationLink(
            destination: BackupsView(),
            label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Text("Restore Data")
                                .subtitleStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                        
                        Text("Automatic backups of your sessions are generated every thirty days. If you need to restore your data, tap here to browse your backed up files.")
                            .calloutStyle()
                            .opacity(0.8)
                            .padding(.top, 1)
                    }
                    Spacer()
                }
            })
        .buttonStyle(PlainButtonStyle())
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
                .buttonStyle(.plain)
        }
    }
    
    var deleteData: some View {
        
        HStack {
            VStack (alignment: .leading) {
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                    showDeleteWarning = true
                    
                } label: {
                    HStack {
                        
                        Text("Erase All Data")
                            .subtitleStyle()
                            .bold()
                        
                        Spacer()
                        
                        Text("›")
                            .font(.title2)
                    }
                }
                .tint(.red)
                .alert(Text("Wait! Are You Sure?"), isPresented: $showDeleteWarning) {
                    
                    Button("Yes", role: .destructive) {
                        deleteUserData()
                    }
                    
                    Button("Cancel", role: .cancel) {
                        print("User cancelled data deletion.")
                    }
                    
                } message: {
                    Text("Pressing Yes below will delete all your saved Session data and Transactions. This action can't be undone.")
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showDeleteSuccessAlertModal, content: {
            AlertModal(message: "You successfully deleted your data.", image: "checkmark.circle", imageColor: .green)
                .presentationDetents([.height(280)])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                .presentationDragIndicator(.visible)
        })
    }
    
    private func deleteUserData() {
        vm.sessions.removeAll()
        vm.transactions.removeAll()
        vm.saveNewSessions()
        vm.bankrolls = vm.bankrolls.map { old in
            var bankroll = old
            bankroll.sessions.removeAll()
            bankroll.transactions.removeAll()
            return bankroll
        }
        
        showDeleteSuccessAlertModal = true
    }
}

#Preview {
    ManageData()
        .environmentObject(SessionsListViewModel())
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}
