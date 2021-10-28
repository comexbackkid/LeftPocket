//
//  MonthlyCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct MonthlyCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                Image(systemName: "doc.text")
                    .foregroundColor(.gray)
                    .font(.title)
                Text("Profit by\nMonth")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                Text("See your results for the previous month.")
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

struct MonthlyCardView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyCardView()
    }
}
