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
                
                // We need to change Scaling Mode so image doesn't distort on home screen
                
                if viewModel.sessions.first?.location.imageURL != "" {
                    if #available(iOS 15.0, *) {
                        
                        AsyncImage(url: URL(string: viewModel.sessions.first?.location.imageURL ?? "default-header")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 340, height: 240)
                                .clipped()
                            
                        } placeholder: {
                            PlaceholderView()
                        }
                        
                    } else {
                        // Fallback on earlier versions
                        // What does this mean exactly? Probably need a default code snippet here.
                    }
                    
                } else {
                    Image(viewModel.sessions.first?.location.localImage ?? "default-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 340, height: 240)
                        .clipped()
                }
                
                Spacer()
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        Text(viewModel.sessions.first?.location.name ?? "No Recent Session")
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
            
            Text("Recent Session")
                .bold()
                .font(.title)
                .foregroundColor(Color(.white))
                .offset(y: -145)
                .padding()
        }
        .frame(width: 340, height: 360)
        .background(Color(.systemBackground))
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
