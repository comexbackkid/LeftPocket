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
    
    @AppStorage("hasClickedRedChipPromo") private var hasClickedRedChipPromo: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @EnvironmentObject var subManager: SubscriptionManager
    @State private var message: String = ""
    @State private var showAlertModal = false

    var body: some View {
        
        ScrollView {
            
            VStack {
                
                title
                
                bodyText
                
                redeemButton
                
                promoSection
                
                Text(message)
                    .padding()
                    .foregroundColor(.red)
            }
        }
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: subManager.isSubscribed) { isSubscribed in
            if isSubscribed {
                showAlertModal = true
                
            } else {
                message = "Please enter a valid offer code."
            }
        }
        .sheet(isPresented: $showAlertModal, content: {
            AlertModal(message: "Offer code redeemed successfully! Enjoy Left Pocket Pro.", image: "checkmark.circle", imageColor: .green)
                .presentationDetents([.height(280)])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
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
    
    var promoSection: some View {
        
        VStack {
            
            HStack {
                Text("Exclusive Red Chip Promo")
                    .cardTitleStyle()
                    .padding(.top, 50)
                
                Spacer()
            }
            
            HStack {
                Text("Try CORE by Red Chip Poker, the most comprehensive A-Z poker course ever created.")
                    .bodyStyle()
                    .padding(.top, 10)
                
                Spacer()
            }
            
            Image("rcp-logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .padding(.top)
                .padding(.bottom, 5)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                hasClickedRedChipPromo = true
                
                guard let url = URL(string: "https://redchippoker.com/checkout/?rid=po68r2&coupon=LeftPocket") else {
                    return
                }
                
                openURL(url)
                
            } label: {
                PrimaryButton(title: "Try CORE for $1")
            }
        }
        .padding(.horizontal)
    }
    
    var redeemButton: some View {
        
        Button {
            Task {
                Purchases.shared.presentCodeRedemptionSheet()
            }
            
        } label: {
            PrimaryButton(title: "Redeem Left Pocket Offer Code")
        }
        .padding(.horizontal)
    }
}

#Preview {
    RedeemOfferCode()
        .preferredColorScheme(.dark)
        .environmentObject(SubscriptionManager())
}
