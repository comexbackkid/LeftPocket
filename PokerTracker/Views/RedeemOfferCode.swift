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
                
                title
                
                bodyText
                
                redeemButton
                
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
            }
        }
        .sheet(isPresented: $showAlertModal, content: {
            AlertModal(message: message, image: "checkmark.circle", imageColor: .green)
                .presentationDetents([.height(280)])
                .presentationBackground(.ultraThinMaterial)
                .presentationDragIndicator(.visible)
        })
    }
    
    var title: some View {
        
        HStack {
            Text("Redeem Offer Code")
                .titleStyle()
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var bodyText: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Tap the button below and you'll be prompted to enter in the offer code that you were given. For any problems, contact support via email from your Settings screen.")
                    .bodyStyle()
                    .padding(.horizontal)
                    .padding(.bottom)
                
                Spacer()
            }
        }
    }
    
    var redeemButton: some View {
        
        Button {
            Task {
                Purchases.shared.presentCodeRedemptionSheet()
            }
            
        } label: {
            PrimaryButton(title: "Redeem Offer Code")
        }
        .padding(.horizontal)
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
