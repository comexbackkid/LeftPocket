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
        
        let featureOne = "• Support for multiple currencies"
        let featureTwo = "• Re-designed reports views for locations, days of the week, and stakes"
        let featureThree = "• Filter Player Stats by cash or tournament"
        let featureFour = "• Minor bug fixes"
        
        ZStack {
            
            VStack {
                Image("product-updates-banner")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, 5)
//                    .ignoresSafeArea(edges: .top)
                
                
                VStack {
                    
                    HStack {
                        Text("NEW in Left Pocket v3.4.3")
                            .subtitleStyle()
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack (alignment: .leading, spacing: 10) {
                            Text("We've brought some exciting new features to Left Pocket that we hope you'll enjoy:")
                                .padding(.bottom, 5)
                                .padding(.top, 10)
                            
                            Text(featureOne)
                            Text(featureTwo)
                            Text(featureThree)
                            Text(featureFour)
                        }
                        Spacer()
                    }
                    .font(.custom("Asap-Regular", size: 16, relativeTo: .body))
                    .lineSpacing(2.5)
                    .padding(.vertical, 5)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .background(Image("defaultlocation-header").resizable().offset(y: 175).overlay(.regularMaterial))
        
        
    }
}

#Preview {
    ProductUpdates(activeSheet: .constant(.productUpdates))
        .preferredColorScheme(.dark)
}
