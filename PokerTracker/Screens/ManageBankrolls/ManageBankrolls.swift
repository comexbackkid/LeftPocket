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
    @State private var showAlert = false
    @State private var selectedBankroll: Bankroll? = nil
    @AppStorage("multipleBankrollsEnabled") var multipleBankrollsEnabled: Bool = false
    let bankrollsTip = MultipleBankrolls()
    
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
                        
                        BankrollCellView(
                            bankroll: Bankroll(name: "Default Bankroll", sessions: vm.sessions, transactions: vm.transactions),
                            currency: .USD
                        )
                        .padding(.vertical, 4)
                        .listRowBackground(Color.brandBackground)
                        
                        ForEach(vm.bankrolls) { bankroll in
                            BankrollCellView(bankroll: bankroll, currency: .USD)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        let impact = UIImpactFeedbackGenerator(style: .soft)
                                        impact.impactOccurred()
                                        selectedBankroll = bankroll
                                        showAlert = true
                                        
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(Color.brandBackground)
                        }
                    }
                    .listStyle(.plain)
                    .alert("Are You Sure?", isPresented: $showAlert, presenting: selectedBankroll) { bankroll in
                        Button("Delete", role: .destructive) {
                            withAnimation {
                                deleteBankroll(bankroll)
                            }
                            selectedBankroll = nil
                        }
                        Button("Cancel", role: .cancel) {
                            selectedBankroll = nil
                        }
                    } message: { _ in
                        Text("This action can't be undone, and you will lose all Sessions in this bankroll.")
                    }
                                        
                } else {
                    
                    Group {
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .heavy)
                            impact.impactOccurred()
                            showSuccessModal = true
                            
                        } label: {
                            PrimaryButton(title: "Enable Multiple Bankrolls")
                                .padding(.horizontal)
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
                    .presentationDetents([.height(400), .large])
                    .presentationBackground(.ultraThinMaterial)
            }
        }
        .toolbar {
            addBankrollButton
                .popoverTip(bankrollsTip)
                .tipViewStyle(CustomTipViewStyle())
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
        
        HStack {
            Text("Use this screen if you want to manage separate bankrolls. For example, you may have a different bankroll for tracking online poker.")
                .bodyStyle()
                .padding(.bottom, 30)
            
            Spacer()
        }
    }
    
    var addBankrollButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            showAddNewBankroll = true
            bankrollsTip.invalidate(reason: .actionPerformed)
            
        } label: {
            Image(systemName: "plus.circle.fill")
                .tint(Color.brandPrimary)
                .fontWeight(.black)
        }
    }
    
    private func deleteBankroll(_ bankroll: Bankroll) {
        if let index = vm.bankrolls.firstIndex(where: { $0.id == bankroll.id }) {
            vm.bankrolls.remove(at: index)
        }
    }
}

#Preview {
    ManageBankrolls()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
