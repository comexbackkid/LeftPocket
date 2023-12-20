//
//  HelpView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/28/21.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Using Left Pocket")
                    .titleStyle()
                    .padding(.top, -37)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            VStack {
                    
                    Image(systemName: "suit.spade.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.bottom, 10)
                        .opacity(0.5)
                    
                    Text("Begin by going to the Settings screen and adding in some of your favorite locations you play at.")
                        .calloutStyle()
                        .lineSpacing(2)
                        .padding(.bottom)
                        .font(.callout)
                    
                    Image(systemName: "suit.heart.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                        .opacity(0.5)
                    
                    Text("Add your first Session. Include things like the location, duration, profit, and any notes you may have took.")
                        .calloutStyle()
                        .lineSpacing(2)
                        .padding(.bottom)
                        .font(.callout)
                    
                    Image(systemName: "suit.diamond.fill")
                        .resizable()
                        .frame(width: 26, height: 30)
                        .padding(.bottom, 10)
                        .foregroundColor(.blue)
                        .opacity(0.5)
                    
                    Text("After you've notched a few sessions you'll be able to visually track your results, bankroll, and other helpful metrics.")
                        .calloutStyle()
                        .lineSpacing(2)
                        .padding(.bottom)
                        .font(.callout)
                }
                .padding(.horizontal, 40)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.brandBlack)
        }
        .background(Color.brandBlack)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .preferredColorScheme(.dark)
    }
}
