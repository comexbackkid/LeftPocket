//
//  LiveSessionInitialBuyIn.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 9/16/24.
//

import SwiftUI

struct LiveSessionInitialBuyIn: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: SessionsListViewModel
    @ObservedObject var timerViewModel: TimerViewModel
    @State private var alertItem: AlertItem?
    @Binding var buyInConfirmationSound: Bool
    
    var body: some View {
        
        VStack {
            
            title
            
            VStack (spacing: 10) {
                
                instructions
            }
            
            inputFields
            
            saveButton
            
            Spacer()
        }
        .dynamicTypeSize(.medium)
        .ignoresSafeArea()
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message, dismissButton: alert.dismissButton)
        }
        .onAppear(perform: {
            buyInConfirmationSound = false
        })
    }
    
    var title: some View {
        
        HStack {
            
            Text("Enter Buy In")
                .font(.custom("Asap-Black", size: 34))
                .bold()
                .padding(.bottom, 5)
                .padding(.top, 20)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Enter your initial Buy In amount. Add rebuys later by tapping & holding on the Live Session indicator bar. Tournament rebuys must equal your initial buy in amount.")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    var inputFields: some View {
        
        HStack {
            Text(vm.userCurrency.symbol)
                .font(.callout)
                .foregroundColor(timerViewModel.initialBuyInAmount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
            
            TextField("Initial Buy In", text: $timerViewModel.initialBuyInAmount)
                .font(.custom("Asap-Regular", size: 17))
                .keyboardType(.numberPad)
        }
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    var saveButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            buyInConfirmationSound = true
            saveButtonPressed()
            
        } label: { PrimaryButton(title: "Save") }
    }
    
    private var isValidForm: Bool {
        guard !timerViewModel.initialBuyInAmount.isEmpty else {
            alertItem = AlertContext.invalidBuyIn
            return false
        }
        
        return true
    }
    
    private func saveButtonPressed() {
        guard isValidForm else { return }
        timerViewModel.addRebuy()
        dismiss()
    }
}

#Preview {
    LiveSessionInitialBuyIn(timerViewModel: TimerViewModel(), buyInConfirmationSound: .constant(false))
        .environmentObject(SessionsListViewModel())
}
