//
//  WeekdayResultsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/6/21.
//

import SwiftUI

struct FilterCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let image: String
    let imageColor: Color
    let title: String
    let description: String
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                
                Image(systemName: image)
                    .foregroundColor(imageColor)
                    .font(.title)
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                Text(description)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
            }
            .frame(width: 130, height: 140)
            .padding()
        }
        .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.2),
                radius: 6, x: 0, y: 3)
    }
}

struct FilterCardView_Previews: PreviewProvider {
    static var previews: some View {
        FilterCardView(image: "calendar",
                       imageColor: .blue,
                       title: "Sample Title\nTwo Lines",
                       description: "Enter the description for this card view here.")
    }
}
