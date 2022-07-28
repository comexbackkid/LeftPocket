//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct RecentSessionCardView: View {
    
    var pokerSession: PokerSession
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            VStack (alignment: .leading) {
                
                if pokerSession.location.imageURL != "" {
                    
                    AsyncImage(url: URL(string: pokerSession.location.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 340, height: 240)
                            .clipped()
                        
                    } placeholder: {
                        PlaceholderView()
                            .frame(width: 340, height: 240)
                    }
                  
                } else {
                    Image(pokerSession.location.localImage != "" ? pokerSession.location.localImage : "default-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 340, height: 240)
                        .clipped()
                }
                
                Spacer()
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        Text(pokerSession.location.name)
                            .font(.title3)
                            .bold()
                        
                        Text("See your most recent session to review hand notes & other details.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            
            Text("Last Session")
                .bold()
                .font(.title)
                .foregroundColor(Color(.white))
                .offset(y: -145)
                .padding()
        }
        .frame(width: 340, height: 360)
        .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.3),
                radius: 12, x: 0, y: 5)
    }
}

struct RecentSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionCardView(pokerSession: MockData.sampleSession).environmentObject(SessionsListViewModel())
    }
}
