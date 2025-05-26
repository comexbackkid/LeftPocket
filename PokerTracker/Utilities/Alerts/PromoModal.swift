//
//  PromoModal.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/22/25.
//

import SwiftUI

struct PromoModal: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    let message: LocalizedStringResource
    let image: String?
    
    init(message: LocalizedStringResource, image: String? = nil) {
        self.message = message
        self.image = image
    }
    
    var body: some View {
        
        VStack {
            
            title
            
            if let image = image {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .padding(.top)
                    .padding(.bottom, 5)
            }
            
            messageBody
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                dismiss()
                
            } label: {
                PrimaryButton(title: "Try CORE for Just $1")
            }
            .padding(.horizontal)
            .padding(.bottom, 25)
            
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.large)
        .ignoresSafeArea()
    }
    
    var title: some View {
        
        HStack {
            
            Spacer()
            
            Text("Feeling Stuck?")
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
    PromoModal(message: "Try CORE by Red Chip Poker, the most comprehensive A-Z poker course ever created.", image: "rcp-logo")
        .frame(height: 360)
}
