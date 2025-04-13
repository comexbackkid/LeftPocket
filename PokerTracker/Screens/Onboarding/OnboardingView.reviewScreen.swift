//
//  OnboardingView.reviewScreen.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/13/25.
//

import SwiftUI

struct ReviewScreen: View {
    
    let showDismissButton: Bool
    var nextAction: () -> Void
    private var isZoomed: Bool {
        UIScreen.main.scale < UIScreen.main.nativeScale
    }
    
    @State private var selectedButton: UserGameImprovement?
    @Binding var shouldShowOnboarding: Bool
    @AppStorage("userGameImprovementSelection") var userGameImprovementSelection = UserGameImprovement.bankroll.rawValue
    
    var body: some View {
        
        VStack {
            
            ScrollView {
                
                VStack {
                    
                    VStack (alignment: .leading) {
                        
                        Text("Leave a Review?")
                            .signInTitleStyle()
                            .foregroundColor(.brandWhite)
                            .fontWeight(.black)
                            .padding(.bottom, 10)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(isZoomed ? 0.5 : 1.0)
                        
                        Text("Help the Left Pocket community grow by spreading the love and leaving us a 5-star review.")
                            .calloutStyle()
                            .opacity(0.7)
                        
                        VStack {
                            
                            HStack {
                                Spacer()
                                Image(systemName: "laurel.leading")
                                    .imageScale(.large)
                                    .fontWeight(.black)
                                Text("4.7")
                                    .font(.custom("Asap-Black", size: 42))
                                    .bold()
                                Image(systemName: "laurel.trailing")
                                    .imageScale(.large)
                                    .fontWeight(.black)
                                Spacer()
                            }
                            .padding(.top)
                            
                            Text("Avg. Customer Rating")
                                .captionStyle()
                            
                            HStack (spacing: 5) {
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                            }
                            .imageScale(.large)
                            .fontWeight(.black)
                            .foregroundStyle(.orange)
                            .padding(.top, 5)
                        }
                        
                        // MARK: FIRST REVIEW
                        HStack {
                            
                            VStack (alignment: .leading, spacing: 5) {
                                
                                Text("Poker players best friend")
                                    .headlineStyle()
                                
                                Text("This app is constantly improving with player feedback, and it's clear that the team behind it is dedicated to providing the best experience.")
                                    .calloutStyle()
                                    .multilineTextAlignment(.leading)
                                
                                HStack (spacing: 0) {
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                }
                                .foregroundStyle(.orange)
                                .padding(.top)
                                
                                Text("Gitgudumiss, 2/12/2025")
                                    .captionStyle()
                                    .foregroundStyle(.secondary)
                                
                            }
                            
                            Spacer()
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(25)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        .font(.custom("Asap-Regular", size: 16))
                        .padding(.top, 30)
                        
                        // MARK: SECOND REVIEW
                        HStack {
                            
                            VStack (alignment: .leading, spacing: 5) {
                                
                                Text("Great app!")
                                    .headlineStyle()
                                
                                Text("One of the better apps out to track your wins and losses and keep track of your poker bankroll. It’s aesthetically pleasing and looks like they are frequently updating!")
                                    .calloutStyle()
                                    .multilineTextAlignment(.leading)
                                
                                HStack (spacing: 0) {
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                }
                                .foregroundStyle(.orange)
                                .padding(.top)
                                
                                Text("Moto508, 1/12/2025")
                                    .captionStyle()
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(25)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        .font(.custom("Asap-Regular", size: 16))
                        
                        // MARK: THIRD REVIEW
                        HStack {
                            
                            VStack (alignment: .leading, spacing: 5) {
                                
                                Text("Great tool")
                                    .headlineStyle()
                                
                                Text("Excellent and easy to use app for keeping track of your game play. Highly recommend for any poker player.")
                                    .calloutStyle()
                                    .multilineTextAlignment(.leading)
                                
                                HStack (spacing: 0) {
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                    Image(systemName: "star.fill")
                                }
                                .foregroundStyle(.orange)
                                .padding(.top)
                                
                                Text("audioguy13, 1/11/2022")
                                    .captionStyle()
                                    .foregroundStyle(.secondary)
                                
                            }
                            
                            Spacer()
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(25)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        .font(.custom("Asap-Regular", size: 16))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                AppReviewRequest.requestReviewIfNeeded()
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
