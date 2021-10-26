//
//  WeekdayResultsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/6/21.
//

import SwiftUI

struct WeekdayCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                Image(systemName: "calendar")
                    .foregroundColor(Color("brandPrimary"))
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Text("Profit by\nWeekday")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                Text("See how you perform on a given day of the week.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 140, height: 140)
            .padding()
        }
        
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.4),
                radius: 10, x: 0, y: 3)
        
    }
}

struct WeekdayCardView_Previews: PreviewProvider {
    static var previews: some View {
        WeekdayCardView()
    }
}
