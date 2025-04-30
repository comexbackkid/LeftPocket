//
//  OnboardingView.poll.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/19/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct PollView: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    
    @State private var selectedButton: UserGameImprovement?
    @Binding var shouldShowOnboarding: Bool
    @AppStorage("userGameImprovementSelection") var userGameImprovementSelection = UserGameImprovement.bankroll.rawValue
    private var isZoomed: Bool { UIScreen.main.scale < UIScreen.main.nativeScale }
    
    var body: some View {
        
        VStack {
            
            VStack (alignment: .leading) {
                
                Spacer()
                
                Text("What is your primary focus with poker right now?")
                    .signInTitleStyle()
                    .foregroundColor(.brandWhite)
                    .fontWeight(.black)
                    .padding(.bottom, 10)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(isZoomed ? 0.5 : 1.0)

                Text("Make your selection below.")
                    .calloutStyle()
                    .opacity(0.7)
                    .padding(.bottom, 30)
                
                let columns = [GridItem(.adaptive(minimum: 160, maximum: 170)), GridItem(.adaptive(minimum: 160, maximum: 170))]
                
                LazyVGrid(columns: columns) {
                    ForEach(UserGameImprovement.allCases, id: \.self) { text in
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            if selectedButton == text {
                                    selectedButton = nil
                                } else {
                                    selectedButton = text
                                }
                            
                        } label: {
                            Text(text.description)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .frame(height: isZoomed ? 60 : 70)
                                .padding(12)
                                .background(.thinMaterial)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedButton == text ? Color.lightGreen : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .font(.custom("Asap-Regular", size: 16))
                .fontWeight(.heavy)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                userGameImprovementSelection = selectedButton?.rawValue ?? "bankroll"
                Purchases.shared.attribution.setAttributes(["user-game-improvement-selection" : userGameImprovementSelection])
                Purchases.shared.syncAttributesAndOfferingsIfNeeded { _, error in
                    if error == nil {
                        nextAction()
                    } else {
                        nextAction()
                    }
                }
                
            } label: {
                Text(showDismissButton ? "Let's Do It" : "Continue")
                    .buttonTextStyle()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedButton == nil ? .gray.opacity(0.75) : .white)
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
            }
            .buttonStyle(PlainButtonStyle())
            .allowsHitTesting(selectedButton == nil ? false : true)
        }
    }
}

enum UserGameImprovement: String, CaseIterable {
    case bankroll, stakes, mental, hands, expenses, busting
    
    var description: String {
        switch self {
        case .bankroll: "Bankroll Management"
        case .stakes: "Climbing Stakes"
        case .mental: "Mental Game"
        case .hands: "Hand Histories"
        case .expenses: "Tracking Expenses"
        case .busting: "Not Going Bust"
        }
    }
}
