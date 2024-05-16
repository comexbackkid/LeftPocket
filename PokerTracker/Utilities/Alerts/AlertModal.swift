//
//  AlertModal.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/15/24.
//

import SwiftUI

struct AlertModal: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let message: String
    
    var body: some View {
        
        VStack {
            
            title
            
            messageBody
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                dismiss()
            } label: { PrimaryButton(title: "OK") }
            
            Spacer()
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.large)
        .ignoresSafeArea()
    }
    
    var title: some View {
        
        HStack {
            
            Text("Success!")
                .titleStyle()
                .padding(.horizontal)
                .padding(.bottom, -20)
            
            Spacer()
        }
        
    }
    
    var messageBody: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text(message)
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AlertModal(message: "Enter alert message here.")
}
