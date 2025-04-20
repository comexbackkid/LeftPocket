//
//  CustomMarkupAmount.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/19/25.
//

import SwiftUI

struct CustomMarkupAmount: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var markup: Double
    @State private var markupAmount: String = ""
    @State private var alertItem: AlertItem?
    
    var body: some View {
        
        VStack {
            
            title
            
            instructions
            
            inputFields
            
            buttons
            
            Spacer()
        }
        .dynamicTypeSize(.medium)
        .alert(item: $alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
    }
    
    private func saveMarkup(dismiss: () -> Void) {
        let markupAmount = Double(markupAmount) ?? 1.0
        markup = markupAmount
        
        dismiss()
    }
    
    var title: some View {
        
        HStack {
            
            Text("Custom Markup")
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
                Text("Enter the amount of markup you're charging for this tournament package.")
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
        
        HStack {
            Image(systemName: "percent")
                .font(.headline).frame(width: 25)
                .foregroundColor(.secondary)
                .padding(.trailing, 10)
            
            TextField("Markup Amount", text: $markupAmount)
                .keyboardType(.decimalPad)
                .font(.custom("Asap-Regular", size: 17))
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var buttons: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                saveMarkup {
                    dismiss()
                }
                
            } label: {
                PrimaryButton(title: "Save")
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
        }
    }
}

#Preview {
    CustomMarkupAmount(markup: .constant(1.15))
}
