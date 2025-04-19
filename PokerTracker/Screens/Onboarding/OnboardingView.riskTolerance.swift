//
//  OnboardingView.riskTolerance.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/19/25.
//

import SwiftUI

struct RiskTolerance: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @State private var selectedTolerance: String? = nil
    @Binding var shouldShowOnboarding: Bool
    @AppStorage("userRiskTolerance") private var selectedRiskTolerance: String = UserRiskTolerance.moderate.rawValue
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("How would you describe your risk tolerance?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Text("This will help us establish a target bankroll size prior to jumping stakes.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 40)
                
                ForEach(UserRiskTolerance.allCases, id: \.self) { tolerance in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        selectedTolerance = tolerance.rawValue
                        selectedRiskTolerance = selectedTolerance ?? "Conservative"
                        
                    } label: {
                        Text(tolerance.rawValue)
                            .font(.custom("Asap-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.thinMaterial)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        selectedTolerance == tolerance.rawValue ? Color.lightGreen : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 5)
                }
                
                Spacer()
        
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                print("User's selected risk tolerance is: \(selectedRiskTolerance)")
                nextAction()
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Continue")
                    .buttonTextStyle()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedTolerance == nil ? .gray.opacity(0.75) : .white)
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
            .allowsHitTesting(selectedTolerance == nil ? false : true)
        }
    }
}


