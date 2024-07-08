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
    
    let width = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading, spacing: 0) {
         
                VStack {
                    Image("nightsky")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width)
                        .clipped()
                        .frame(maxHeight: 250)
                }
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text("Measure Sleep Correlation")
                            .headlineStyle()
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                        Text("Ever wonder how sleep affects your poker game? Explore the data here.")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .padding(.bottom, 10)
                        
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(width: width, height: 110)
                .background(
                    Image("nightsky")
                        .resizable()
                        .clipped()
                        .overlay(.ultraThinMaterial)
                )
            }
            
            VStack (alignment: .leading) {
                
                Text("EXAMINE")
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.5)
                
                Text("Sleep Analytics")
                    .signInTitleStyle()
                    .fontWeight(.heavy)
                    .foregroundColor(Color(.white))
                
                Spacer()
            }
            .padding()
            
        }
        .frame(width: width, height: 360)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

#Preview {
    SleepCardView()
}
