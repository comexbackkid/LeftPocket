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
    
    var body: some View {
        
        VStack {
            
            title
            
            instructions
            
            HStack {
        
                TextField("Bankroll name", text: $bankrollName)
                    .font(.custom("Asap-Regular", size: 17))
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            
            Button {
                
                
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
}

#Preview {
    AddNewBankroll()
        .environmentObject(SessionsListViewModel())
}
