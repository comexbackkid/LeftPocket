//
//  ManageBankrolls.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/31/25.
//

import SwiftUI

struct ManageBankrolls: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showAddNewBankroll = false
    @State private var showSuccessModal = false
//    @AppStorage("multipleBankrollsEnabled") var multipleBankrollsEnabled: Bool = false
    @State private var multipleBankrollsEnabled = false
    @State private var showProgressBar = false
    
    var body: some View {
        
        NavigationStack {
            
            VStack (alignment: .leading) {
                
                VStack {
                    
                    title
                    
                    instructions
                }
                .padding(.horizontal)
                
                if multipleBankrollsEnabled {
                    List {
                        
                        Text("My Bankrolls")
                            .headlineStyle()
                            .listRowBackground(Color.brandBackground)
                        
                        ForEach(vm.tempBankrolls) { bankroll in
                            BankrollCellView(bankroll: bankroll, currency: .USD)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        let impact = UIImpactFeedbackGenerator(style: .soft)
                                        impact.impactOccurred()
                                        
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                                .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.brandBackground)
                    }
                    .listStyle(.plain)
                    
                    addBankrollButton
                    
                } else {
                    
                    Group {
                        if showProgressBar {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding(.top, 25)
                                Spacer()
                            }
                            
                        } else {
                            Button {
                                showSuccessModal = true
                                showProgressBar = true
                                
                            } label: {
                                PrimaryButton(title: "Enable Multiple Bankrolls")
                                    .padding(.horizontal)
                            }
                            
                        }
                    }
                    .sheet(isPresented: $showSuccessModal) {
                        multipleBankrollsEnabled = true
                    } content: {
                        AlertModal(message: "You've enabled multiple bankrolls.")
                            .dynamicTypeSize(.medium)
                            .presentationDetents([.height(210)])
                            .presentationBackground(.ultraThinMaterial)
                    }
                }
                
                Spacer()
            }
            .background(Color.brandBackground)
            .sheet(isPresented: $showAddNewBankroll) {
                AddNewBankroll()
                    .presentationDetents([.height(340), .large])
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
    
    var title: some View {
        
        HStack {
            Text("Manage Bankrolls")
                .titleStyle()
            
            Spacer()
        }
    }
    
    var instructions: some View {
        
        Text("Use this screen to manage multiple bankrolls. For example you may have a separate bankroll for online poker.")
            .bodyStyle()
            .padding(.bottom, 30)
    }
    
    var addBankrollButton: some View {
        
        Button {
            showAddNewBankroll = true
            
        } label: {
            PrimaryButton(title: "Add a Bankroll")
        }
        .padding(.horizontal)
    }
}

#Preview {
    ManageBankrolls()
        .environmentObject(SessionsListViewModel())
}
