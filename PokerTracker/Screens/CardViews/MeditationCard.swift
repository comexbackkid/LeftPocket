//
//  MeditationCard.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/23/25.
//

import SwiftUI

struct MeditationCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading) {

                VStack {
                    Image("meditation-forest")
                        .centerCropped()
                }
                .frame(maxHeight: 250)
                .clipped()
                
                Spacer()
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Your Mind is a Weapon")
                            .headlineStyle()
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                        Text("Find the right headspace before you sit down at the poker table in just 5 minutes.")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                    }
                    .padding()
                    .padding(.top, -8)
                    .dynamicTypeSize(...DynamicTypeSize.large)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .background(
                ZStack {
                    Image("meditation-forest")
                        .overlay(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                }
            )
            
            VStack (alignment: .leading) {
                
                Text("MEDITATION")
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.5)
                
                Text("Forest Ambiance")
                    .signInTitleStyle()
                    .fontWeight(.heavy)
                    .foregroundColor(Color(.white))
                
                Spacer()
            }
            
            .padding()
                
        }
        .frame(height: 360)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

#Preview {
    MeditationCard()
}
