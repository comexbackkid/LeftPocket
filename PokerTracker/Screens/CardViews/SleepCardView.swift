//
//  SleepCardView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/14/24.
//

import SwiftUI

struct SleepCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading, spacing: 0) {
         
                VStack {
                    Image("nightsky")
                        .centerCropped()
                }
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Sleep & Mindfulness Correlation")
                            .headlineStyle()
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                        Text("Ever wonder how sleep, mindfulness and mood affect your poker game?")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .padding(.bottom, 10)
                        
                    }
                    .padding()
                    .dynamicTypeSize(...DynamicTypeSize.large)
                    
                    Spacer()
                }
                .frame(height: 110)
                .background(
                    Image("nightsky")
                        .resizable()
                        .clipped()
                        .blur(radius: 20)
                        .overlay(.ultraThinMaterial)
                )
            }
            
            VStack (alignment: .leading) {
                
                Text("EXAMINE")
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.5)
                
                Text("Health Analytics")
                    .signInTitleStyle()
                    .fontWeight(.heavy)
                    .foregroundColor(Color(.white))
                
                Spacer()
            }
            .padding()
            
        }
        .frame(height: 300)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

#Preview {
    SleepCardView()
}
