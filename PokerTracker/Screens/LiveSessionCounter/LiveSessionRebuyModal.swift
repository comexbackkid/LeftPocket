//
//  LiveSessionRebuyModal.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/13/24.
//

import SwiftUI

struct LiveSessionRebuyModal: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    @State private var alertItem: AlertItem?
    @Binding var rebuyConfirmationSound: Bool
    
    var body: some View {
        
        VStack {
            
            title
            
            VStack (spacing: 10) {
                
                instructions
                
                HStack (alignment: .top, spacing: 6) {
                    
                    Text("Rebuy Total")
                        .bodyStyle()
                        .foregroundStyle(.secondary)
                        .fontWeight(.black)
                        .padding(.bottom, 5)
                    
                    Text("$\(timerViewModel.rebuyTotalForSession)")
                        .bodyStyle()
                        .foregroundStyle(timerViewModel.rebuyTotalForSession == 0 ? Color.secondary : .red)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            inputFields
            
            saveButton
           
            Spacer()
        }
        .onAppear(perform: {
            rebuyConfirmationSound = false
        })
        .dynamicTypeSize(.medium)
        .ignoresSafeArea()
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message, dismissButton: alert.dismissButton)
        }
        .onDisappear(perform: {
            timerViewModel.reBuyAmount = ""
        })
    }
    
    var title: some View {
        
        HStack {
            
            Text("Add Rebuy")
                .titleStyle()
                .padding(.horizontal)
                .padding(.bottom, -20)
            
            Spacer()
        }
        
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("First, enter your original buy-in for this session. Then, your rebuy amount. You can log multiple rebuys if you need to.")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var inputFields: some View {
        
        HStack {
            HStack {
                Text(vm.userCurrency.symbol)
                    .font(.callout)
                    .foregroundColor(timerViewModel.initialBuyInAmount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Buy-In", text: $timerViewModel.initialBuyInAmount)
                    .font(.custom("Asap-Regular", size: 17))
                    .keyboardType(.numberPad)
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.leading)
         
            
            HStack {
                Text(vm.userCurrency.symbol)
                    .font(.callout)
                    .foregroundColor(timerViewModel.reBuyAmount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Rebuy / Top Off", text: $timerViewModel.reBuyAmount)
                    .font(.custom("Asap-Regular", size: 17))
                    .keyboardType(.numberPad)
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.trailing)
        
        }
        
    }
    
    var saveButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            saveButtonPressed()
            rebuyConfirmationSound = true
            
        } label: { PrimaryButton(title: "Add Rebuy") }
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
    LiveSessionRebuyModal(rebuyConfirmationSound: .constant(false))
        .environmentObject(SessionsListViewModel())
        .environmentObject(TimerViewModel())
}
