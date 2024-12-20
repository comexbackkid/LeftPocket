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
        
        Image("sleep-analytics-promo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 260)
            .frame(maxWidth: UIScreen.main.bounds.width)
            .clipped()
            .padding(.bottom, 5)
        
    }
    
    var title: some View {
        
        HStack {
            Text("What's New 🎉")
                .font(.custom("Asap-Black", size: 34))
                .bold()
            
            Spacer()
        }
        
    }
    
    var mainBody: some View {
        
        HStack {
            
            let updates = [
                "Poker Mindfulness is here! Track your meditation habits & correlation to poker results.",
                "Now you can log rebuys for both Completed Sessions & Live Sessions.",
                "Quickly add new Locations and your own custom stakes right from the New Session view.",
            ]
            
            VStack (alignment: .leading, spacing: 20) {
                Text("We've brought some exciting new features to Left Pocket v\(getAppVersion()) that we hope you'll enjoy.")
                    .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                    .padding(.bottom, 30)
                
                HStack (alignment: .center, spacing: 18) {
                    Image(systemName: "figure.mind.and.body")
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
                    Image(systemName: "dollarsign.arrow.circlepath")
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
                    Image(systemName: "mappin")
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
