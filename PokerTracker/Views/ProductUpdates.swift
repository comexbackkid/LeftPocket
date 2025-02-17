//
//  ProductUpdates.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/3/24.
//

import SwiftUI

struct ProductUpdates: View {
    
    @Binding var activeSheet: Sheet?
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                headerImage
                
                VStack (spacing: 7) {
                    
                    title
                    
                    mainBody
                    
                    Spacer()
                }
                .padding()
            }
            
            dismissButton
 
        }
        .background(backgroundImage)
    }
    
    var headerImage: some View {
        
        VStack {
            Text("🎉")
                .font(.custom("Asap-Regular", size: 62))
                .padding(.top, 50)
        }
        
//        Image("sleep-analytics-promo")
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(height: 200)
//            .frame(maxWidth: UIScreen.main.bounds.width)
//            .clipped()
//            .padding(.bottom, 5)
        
    }
    
    var title: some View {
        
        HStack {
            Text("What's New in Left Pocket")
                .font(.custom("Asap-Black", size: 38))
                .bold()
                .multilineTextAlignment(.center)
                .padding(.bottom, 25)
        }
        
    }
    
    var mainBody: some View {
        
        HStack {
            
            let updates = [
                "Tournament bounties are now available to track for Pro subscribers.",
                "Poker Mindfulness is here! Track your meditation habits & correlation to poker results.",
                "Now you can log rebuys for both Completed Sessions & Live Sessions.",
                "Session Tags! Add a tag to your Session for custom grouping & reporting for trips or challenges.",
            ]
            
            VStack (alignment: .leading, spacing: 20) {
                
                HStack (alignment: .center, spacing: 18) {
                    Image(systemName: "scope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandPrimary)
                    
                    Text(updates[0])
                        .bodyStyle()
                }
                .padding(.bottom, 6)
                .padding(.horizontal)
                
                HStack (alignment: .center, spacing: 18) {
                    Image(systemName: "figure.mind.and.body")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandPrimary)
                    
                    Text(updates[1])
                        .bodyStyle()
                }
                .padding(.bottom, 6)
                .padding(.horizontal)
                
                HStack (alignment: .center, spacing: 18) {
                    Image(systemName: "dollarsign.arrow.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandPrimary)
                    
                    Text(updates[2])
                        .bodyStyle()
                }
                .padding(.bottom, 6)
                .padding(.horizontal)
                
                HStack (alignment: .center, spacing: 18) {
                    Image(systemName: "tag.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.brandPrimary)
                    
                    Text(updates[3])
                        .bodyStyle()
                }
                .padding(.bottom, 6)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .lineSpacing(2.5)
    }
    
    var backgroundImage: some View {
        
        Image("encore-header2")
            .resizable()
            .scaledToFill()
            .offset(y: 100)
            .overlay(.regularMaterial)
        
    }
    
    var dismissButton: some View {
        
        VStack {
            HStack {
                Spacer()
                DismissButton()
                    .onTapGesture {
                        activeSheet = nil
                    }
            }
            Spacer()
        }
        .padding()
        
    }
    
    func getAppVersion() -> String {
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        
        return "Unknown"
    }
}

#Preview {
    ProductUpdates(activeSheet: .constant(.productUpdates))
        .preferredColorScheme(.dark)
}
