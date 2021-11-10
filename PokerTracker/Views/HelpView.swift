//
//  HelpView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/28/21.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        
        ZStack {
            VStack {
                LinearGradient(gradient: Gradient(colors: [Color("brandWhite"), .white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            }
            .ignoresSafeArea()
            
            VStack {
                Image(systemName: "suit.spade.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.bottom, 10)
                
                Text("Begin by going to Settings and adding in some of the locations you play at.")
                    .padding(.bottom)
                    .font(.callout)
                
                
                Image(systemName: "suit.heart.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
                
                Text("Add your first Session. Include things like the location, duration, profit, and any notes you took from the session.")
                    .padding(.bottom)
                    .font(.callout)
                
                
                Image(systemName: "suit.diamond.fill")
                    .resizable()
                    .frame(width: 26, height: 30)
                    .padding(.bottom, 10)
                    .foregroundColor(.blue)
                
                Text("After you've got a few sessions under your belt you'll start to be able to track your results and bankroll.")
                    .padding(.bottom)
                    .font(.callout)
            }
            .padding(.horizontal, 40)
            
        }
        .navigationBarTitle("Using PokerTracker")
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
