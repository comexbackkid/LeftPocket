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
                Image(systemName: "suit.spade.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.bottom, 10)
                    .opacity(0.5)
                
                Text("Begin by going to Settings and adding in some of the locations you play at.")
                    .padding(.bottom)
                    .font(.callout)
                
                
                Image(systemName: "suit.heart.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
                    .opacity(0.5)
                
                Text("Add your first Session. Include things like the location, duration, profit, and any notes you took from the session.")
                    .padding(.bottom)
                    .font(.callout)
                
                
                Image(systemName: "suit.diamond.fill")
                    .resizable()
                    .frame(width: 26, height: 30)
                    .padding(.bottom, 10)
                    .foregroundColor(.blue)
                    .opacity(0.5)
                
                Text("After you've notched a few sessions on your belt you'll be able to visuall track your results and bankroll.")
                    .padding(.bottom)
                    .font(.callout)
            }
            .padding(.horizontal, 40)
            .navigationBarTitle("Using PokerTracker")
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
