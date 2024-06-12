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
        
        let updates = [
            "Sleep Analytics is here! Available to all Pro subscribers, accessible directly from Dashboard screen or at the bottom of Metrics screen.",
            "Live Session now supports rebuy / top-offs.",
            "Add new Locations and custom stakes right from the New Session view.",
        ]
        
        ZStack {
            
            VStack {
                Image("product-updates-header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .padding(.bottom, 5)
                
                VStack (spacing: 7) {
                    
                    HStack {
                        Text("New in Left Pocket v" + getAppVersion())
                            .cardTitleStyle()
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack (alignment: .leading, spacing: 10) {
                            Text("We've brought some exciting new features to Left Pocket that we hope you'll enjoy...")
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
                    
                    Spacer()
                }
                .padding()
            }
        }
        .background(Image("defaultlocation-header").resizable().offset(y: 175).overlay(.regularMaterial))
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
