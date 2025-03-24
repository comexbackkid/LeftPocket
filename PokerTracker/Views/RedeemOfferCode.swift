//
//  RedeemOfferCode.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/3/24.
//

import SwiftUI
import StoreKit
import RevenueCat

struct RedeemOfferCode: View {
    
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var message: String = ""
    @State private var showAlertModal = false

    var body: some View {
        
        ScrollView {
            
            VStack {
                HStack {
                    Text("Redeem Offer Code")
                        .titleStyle()
                        .padding(.horizontal)
                    
                    Spacer()
                }
                
                VStack (alignment: .leading) {
                    
                    HStack {
                        Text("Tap the button below and you'll be prompted to enter in the offer code that you were sent.")
                            .bodyStyle()
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                        Spacer()
                    }
                }
                
                Button {
                    redeemOfferCode()
//                    Task {
//                        Purchases.shared.presentCodeRedemptionSheet()
//                    }
                    
                } label: {
                    PrimaryButton(title: "Redeem Offer Code")
                }
                
                Text(message)
                    .padding()
                    .foregroundColor(.red)
            }
            
        }
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: subManager.isSubscribed) { isSubscribed in
            if isSubscribed {
                message = "Offer code redeemed successfully! Enjoy Left Pocket Pro."
                showAlertModal = true
                
            } else {
                message = "Please enter a valid offer code."
                print("There was an error with your offer code.")
            }
        }
        .sheet(isPresented: $showAlertModal, content: {
            AlertModal(message: message)
                .presentationDetents([.height(220)])
                .presentationBackground(.ultraThinMaterial)
            
        })
    }

    private func redeemOfferCode() {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.presentCodeRedemptionSheet()
    }
}

#Preview {
    RedeemOfferCode()
        .preferredColorScheme(.dark)
        .environmentObject(SubscriptionManager())
}
