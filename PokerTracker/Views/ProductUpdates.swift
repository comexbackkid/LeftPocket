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
            "Support for multiple currencies",
            "Re-designed reports views for locations, days of the week, and stakes",
            "Filter Player Stats by cash or tournament",
            "Add a new location directly from New Session screen",
            "Minor bug fixes"
        ]
        
        ZStack {
            
            VStack {
                Image("product-updates-banner")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, 5)
                
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
                            
                            ForEach(updates, id: \.self) { feature in
                                HStack (alignment: .firstTextBaseline) {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                    Text(feature)
                                }
                            }
                        }
                        Spacer()
                    }
                    .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
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
