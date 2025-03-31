//
//  ManageBankrolls.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/31/25.
//

import SwiftUI

struct ManageBankrolls: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    let tempBankrolls: [Bankroll] = [Bankroll(name: "Default Bankroll", sessions: MockData.allSessions),
                                     Bankroll(name: "Online Bankroll", sessions: MockData.allSessions)]
    
    var body: some View {
        
        NavigationStack {
            
            VStack (alignment: .leading) {
                
                VStack {
                    
                    HStack {
                        Text("Manage Bankrolls")
                            .titleStyle()
                        
                        Spacer()
                    }
                    
                    Text("Use this screen to manage multiple bankrolls. For example you may have a separate bankroll for online poker.")
                        .bodyStyle()
                        .padding(.bottom, 50)
                }
                .padding(.horizontal)
                
                List {
                    
                    Text("My Bankrolls")
                        .headlineStyle()
                        .listRowBackground(Color.brandBackground)
                    
                    ForEach(tempBankrolls) { bankroll in
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
                
                Button {
                    // Function to turn on multiple bankrolls
                    
                } label: {
                    PrimaryButton(title: "Add a Bankroll")
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color.brandBackground)
            
        }
        
    }
}

#Preview {
    ManageBankrolls()
        .environmentObject(SessionsListViewModel())
}
