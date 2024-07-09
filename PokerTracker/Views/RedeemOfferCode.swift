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

    var body: some View {
        
        ScrollView {
            
            VStack {
                HStack {
                    Text("Redeem Offer Code")
                        .titleStyle()
                        .padding(.top, -37)
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
                } label: {
                    PrimaryButton(title: "Redeem Offer Code")
                }
                
                Text(message)
                    .padding()
                    .foregroundColor(.red)
            }
            .padding()
        }
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)

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
