//
//  OnboardingView.startingBankroll.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/19/25.
//

import SwiftUI

struct StartingBankroll: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @AppStorage("savedStartingBankroll") private var savedStartingBankroll: String = ""
    @State private var startingBankrollTextField: String = ""
    @Binding var shouldShowOnboarding: Bool
    @FocusState var isFocused: Bool
    private var isZoomed: Bool { UIScreen.main.scale < UIScreen.main.nativeScale }
    
    var body: some View {
        
        VStack {
            
            GeometryReader { geo in
                ScrollView {
                    
                    VStack (alignment: .leading) {
                        
                        Spacer()
                        
                        Text("Are you starting off with a bankroll today?")
                            .signInTitleStyle()
                            .foregroundColor(.brandWhite)
                            .fontWeight(.black)
                            .padding(.bottom, 5)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                        
                        Text("You can skip this step, and import data later from a different bankroll tracker.")
                            .calloutStyle()
                            .opacity(0.7)
                            .padding(.bottom, 20)
                        
                        HStack {
                            
                            Text("$")
                                .font(.system(size: 25))
                                .frame(width: 17)
                                .foregroundColor(startingBankrollTextField.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                            
                            TextField("", text: $startingBankrollTextField)
                                .focused($isFocused, equals: true)
                                .font(.custom("Asap-Bold", size: 25))
                                .keyboardType(.numberPad)
                                .onSubmit {
                                    isFocused = false
                                }
                                .toolbar {
                                    ToolbarItem(placement: .keyboard) {
                                        Button("Done") { isFocused = false }
                                    }
                                }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                        .overlay {
                            if !startingBankrollTextField.isEmpty {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.lightGreen, lineWidth: 1.5)
                            }
                        }
                        
                        Spacer()
                        
                    }
                    .frame(minHeight: geo.size.height)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        isFocused = false
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                nextAction()
                
            } label: {
                Text("Skip this step, I'll decide later")
                    .subHeadlineStyle()
                    .buttonStyle(.plain)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                isFocused = false
                savedStartingBankroll = startingBankrollTextField
                nextAction()
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Continue")
                    .buttonTextStyle()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
