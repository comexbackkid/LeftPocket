//
//  SignInTest.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/12/23.
//

import SwiftUI
import AuthenticationServices

struct SignInTest: View {
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("email") var email: String = ""
    @AppStorage("userID") var userID: String = ""
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    
    @Binding var shouldShowOnboarding: Bool
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Spacer()
                
                Image("leftpocket-logo-simple")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                
                Spacer()
                
                Text("WELCOME TO LEFT POCKET")
                    .foregroundColor(.white)
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.bottom, 1)
                
                Text("Where you keep your important money.")
                    .signInTitleStyle()
                    .bold()
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.bottom, 50)
                
                Spacer()
                
//                appleSignInButton
                
                Button {
                    shouldShowOnboarding.toggle()
                } label: {
                    VStack {
                        Text("Get Started")
                            .buttonTextStyle()
                            .foregroundColor(.black)
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(.white)
                            .cornerRadius(30)
                            .padding(.horizontal, 10)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("By continuing you agree to Left Pocket's Terms of Use and [Privacy Policy](https://getleftpocket.carrd.co/#privacy)")
                    .accentColor(.brandPrimary)
                    .foregroundColor(.white)
                    .font(.footnote)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .background(LinearGradient(colors: [.black.opacity(colorScheme == .dark ? 0.4 : 0.7), .black.opacity(0.0)],
                                   startPoint: .bottomTrailing,
                                   endPoint: .topLeading))
        .background(Color.onboardingBG)
    }
    
    var appleSignInButton: some View {
        
        VStack {
            
            SignInWithAppleButton(.continue) { request in
                
                request.requestedScopes = [.email, .fullName]
                
            } onCompletion: { result in
                
                switch result {
                case .success(let auth):
                    
                    switch auth.credential {
                    case let credential as ASAuthorizationAppleIDCredential:
                        
                        // User ID
                        let userID = credential.user
                        
                        // User Info
                        let email = credential.email
                        let firstName = credential.fullName?.givenName
                        let lastName = credential.fullName?.familyName
                        
                        // Need to go through error checks for all this shit
                        // Because we may or may not get this back from Apple, just handle the optional with blank space
                        self.userID = userID
                        self.email = email ?? ""
                        self.firstName = firstName ?? ""
                        self.lastName = lastName ?? ""
                        
                    default:
                        break
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
            }
            .signInWithAppleButtonStyle(.white)
        }
        .cornerRadius(30)
        .frame(height: 55)
    }
}

struct SignInTest_Previews: PreviewProvider {
    static var previews: some View {
        SignInTest(shouldShowOnboarding: .constant(true))
//            .preferredColorScheme(.dark)
    }
}
