//
//  AddNewBankroll.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/31/25.
//

import SwiftUI

struct AddNewBankroll: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var bankrollName: String = ""
    @State private var startingBankroll: String = ""
    
    var body: some View {
        
        VStack {
            
            title
            
            instructions
            
            inputFields
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                saveBankroll()
                dismiss()
                
            } label: {
                PrimaryButton(title: "Save Bankroll")
                    .padding(.horizontal)
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                dismiss()
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
            
            Spacer()
        }
        .dynamicTypeSize(.medium)
    }
    
    private func saveBankroll() {
        let trimmedName = bankrollName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let startingAmount = Int(startingBankroll) ?? 0
        let startingTransaction = BankrollTransaction(
            date: Date(),
            type: .deposit,
            amount: startingAmount,
            notes: "Starting bankroll",
            tags: nil
        )
        
        let newBankroll = Bankroll(name: trimmedName, sessions: [], transactions: [startingTransaction])
        withAnimation {
            vm.bankrolls.append(newBankroll)
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("Add Bankroll")
                .font(.custom("Asap-Black", size: 34))
                .bold()
                .padding(.top, 20)
                .padding(.horizontal)
                .padding(.bottom, 5)
            
            Spacer()
        }
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Enter the name of your new bankroll. This can't be changed later.")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.bottom, 20)
        .padding(.horizontal)
    }
    
    var inputFields: some View {
        
        VStack {
            
            HStack {
                Image(systemName: "textformat.alt")
                    .font(.headline).frame(width: 25)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 10)
                
                TextField("Bankroll Name", text: $bankrollName)
                    .font(.custom("Asap-Regular", size: 17))
                    .submitLabel(.next)
                
            }
            .padding(.bottom, 8)
            
            Divider()
            
            HStack {
                Image(systemName: "dollarsign")
                    .font(.headline).frame(width: 25)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 10)
                
                TextField("Starting Amount", text: $startingBankroll)
                    .keyboardType(.numberPad)
                    .font(.custom("Asap-Regular", size: 17))
                    .foregroundColor(startingBankroll.isEmpty ? .primary : .brandPrimary)
                
                Spacer()
                    
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    AddNewBankroll()
        .environmentObject(SessionsListViewModel())
}
