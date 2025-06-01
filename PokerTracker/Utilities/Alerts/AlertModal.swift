//
//  AlertModal.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/15/24.
//

import SwiftUI

struct AlertModal: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    let alertTitle: LocalizedStringResource?
    let message: LocalizedStringResource
    let image: String?
    let imageColor: Color?
    let buttonText: LocalizedStringResource?
    var actionToPerform: (() -> Void)?
    var cancelButton: Bool?
    
    init(alertTitle: LocalizedStringResource? = nil, message: LocalizedStringResource, image: String? = nil, imageColor: Color? = nil, buttonText: LocalizedStringResource? = nil, actionToPerform: (() -> Void)? = nil, cancelButton: Bool? = nil) {
        self.alertTitle = alertTitle
        self.message = message
        self.image = image
        self.imageColor = imageColor
        self.buttonText = buttonText
        self.actionToPerform = actionToPerform
        self.cancelButton = cancelButton
    }
    
    var body: some View {
        
        VStack {
            
            title
            
            if let image = image, let imageColor = imageColor {
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .symbolEffect(.bounce, value: isAnimating)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(imageColor)
                    .padding(.top)
                    .padding(.bottom, 5)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                            isAnimating = true
                        })
                    }
            }
            
            messageBody
            
            Spacer()
            
            VStack {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    if let customAction = actionToPerform {
                        customAction()
                        
                    } else {
                        dismiss()
                    }
                    
                } label: {
                    PrimaryButton(title: buttonText ?? "OK")
                }
                
                if cancelButton == true {
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
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.large)
        .ignoresSafeArea()
    }
    
    var title: some View {
        
        HStack {
            
            Spacer()
            
            Text(alertTitle ?? "Success!")
                .font(.custom("Asap-Black", size: 30))
                .bold()
                .padding(.bottom, 5)
                .padding(.top, 25)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var messageBody: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                
                Text(message)
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AlertModal(message: "Enter alert message here.", image: "checkmark.circle", imageColor: Color.green, actionToPerform: {})
        .frame(height: 360)
}
