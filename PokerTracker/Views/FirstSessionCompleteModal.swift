//
//  FirstSessionCompleteModal.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/2/25.
//

import SwiftUI

struct FirstSessionCompleteModal: View {
    
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
            
            Spacer()
            
            if let image = image, let imageColor = imageColor {
                if #available(iOS 18.0, *) {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolEffect(.breathe, options: .repeat(3), value: isAnimating)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(imageColor.gradient)
                        .padding(.top)
                        .padding(.bottom)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                isAnimating = true
                            })
                        }
                } else {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolEffect(.bounce, value: isAnimating)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(imageColor.gradient)
                        .padding(.top)
                        .padding(.bottom)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                isAnimating = true
                            })
                        }
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
            
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.large)
        .ignoresSafeArea()
    }
    
    var title: some View {
        
        HStack {
            
            Spacer()
            
            Text("Congratulations!")
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
    FirstSessionCompleteModal(message: "You've completed your first session! Let the world know and share your progress, accountability helps us grow.", image: "trophy", imageColor: .yellow)
        .frame(height: 400)
}
