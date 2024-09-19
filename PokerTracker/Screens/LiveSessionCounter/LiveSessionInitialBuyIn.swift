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
                Text("Before continuing, please enter your initial Buy In amount for this Live Session. You can add rebuys later by tapping & holding on the Live Session indicator bar.")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var inputFields: some View {
        
        HStack {
            Text(vm.userCurrency.symbol)
                .font(.callout)
                .foregroundColor(timerViewModel.initialBuyInAmount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
            
            TextField("Buy In", text: $timerViewModel.initialBuyInAmount)
                .font(.custom("Asap-Regular", size: 17))
                .keyboardType(.numberPad)
        }
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom)

    }
    
    var saveButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
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
    LiveSessionInitialBuyIn(timerViewModel: TimerViewModel())
        .environmentObject(SessionsListViewModel())
}
