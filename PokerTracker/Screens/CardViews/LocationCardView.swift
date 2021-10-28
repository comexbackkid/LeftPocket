//
//  LocationResultsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/6/21.
//

import SwiftUI

struct LocationCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.red)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Text("Profit by\nLocation")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                Text("Find out which location yields the best return.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 140, height: 140)
            .padding()
        }
        .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.2),
                radius: 6, x: 0, y: 3)
        
    }
}


struct LocationResultsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationCardView()
    }
}
