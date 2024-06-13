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
            Text("What's New in Left Pocket 🎉")
                .cardTitleStyle()
            
            Spacer()
        }
        
    }
    
    var mainBody: some View {
        
        HStack {
            
            let updates = [
                "Sleep Analytics is here! Available to all Pro subscribers, accessible directly from Dashboard screen or at the bottom of Metrics screen.",
                "Live Session now supports rebuy / top-offs. Just tap the rebuy button next to the counter.",
                "Quickly add new Locations and your own custom stakes right from the New Session view. They'll be saved for future sessions.",
            ]
            
            VStack (alignment: .leading, spacing: 10) {
                Text("We've brought some exciting new features to Left Pocket v\(getAppVersion()) that we hope you'll enjoy...")
                    .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                    .padding(.bottom, 20)
                
                ForEach(updates, id: \.self) { feature in
                    HStack (alignment: .firstTextBaseline, spacing: 12) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .fontWeight(.heavy)
                        Text(feature)
                            .calloutStyle()
                    }
                    .padding(.bottom, 6)
                }
            }
            Spacer()
        }
        .lineSpacing(2.5)
        
    }
    
    var backgroundImage: some View {
        
        Image("encore-header")
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
//        .preferredColorScheme(.dark)
}
