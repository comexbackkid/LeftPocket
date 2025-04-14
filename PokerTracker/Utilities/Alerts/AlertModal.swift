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
    
    let message: String
    let image: String?
    let imageColor: Color?
    
    init(message: String, image: String? = nil, imageColor: Color? = nil) {
        self.message = message
        self.image = image
        self.imageColor = imageColor
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
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                dismiss()
                
            } label: {
                PrimaryButton(title: "OK")
            }
            .padding(.horizontal)
            .padding(.bottom, 25)
            
//            Spacer()
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.large)
        .ignoresSafeArea()
    }
    
    var title: some View {
        
        HStack {
            
            Spacer()
            
            Text("Success!")
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
    AlertModal(message: "Enter alert message here.", image: "checkmark.circle", imageColor: Color.green)
        .frame(height: 300)
}
